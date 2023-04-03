// Copyright 2023 RisingWave Labs
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

use risingwave_common::util::column_index_mapping::ColIndexMapping;
use risingwave_pb::plan_common::JoinType;

use super::{BoxedRule, Rule};
use crate::optimizer::plan_node::{LogicalHopWindow, LogicalJoin};
use crate::utils::IndexRewriter;

pub struct PullUpHopRule {}

impl Rule for PullUpHopRule {
    fn apply(&self, plan: crate::PlanRef) -> Option<crate::PlanRef> {
        let join = plan.as_logical_join()?;

        let (left, right, on, join_type, output_index) = join.clone().decompose();

        let (left_input_index_on_condition, right_input_index_on_condition) =
            join.input_idx_on_condition();

        let (mut left_output_index, mut right_output_index) = {
            let mut left_output_index = vec![];
            let mut right_output_index = vec![];
            output_index.into_iter().for_each(|idx| {
                if idx < left.schema().len() {
                    left_output_index.push(idx);
                } else {
                    right_output_index.push(idx - left.schema().len());
                }
            });
            (left_output_index, right_output_index)
        };

        let mut old_i2new_i = ColIndexMapping::empty(0, 0);

        let mut pull_up_left = false;
        let mut pull_up_right = false;

        let (new_left,
            left_time_col,
            left_window_slide,
            left_window_size,
            left_window_offset,
        ) =  if let Some(hop) = left.as_logical_hop_window() &&
            left_input_index_on_condition.iter().all(|&index| hop.output_window_start_col_idx().map_or(true, |v|index!=v) && hop.output_window_end_col_idx().map_or(true, |v|index!=v)) &&
            join_type != JoinType::RightAnti && join_type != JoinType::RightSemi && join_type != JoinType::RightOuter && join_type != JoinType::FullOuter {
                let (input,
                    time_col,
                    window_slide,
                    window_size,
                    window_offset,
                    _) = hop.clone().into_parts();

                old_i2new_i = old_i2new_i.union(&join.i2l_col_mapping_ignore_join_type().composite(&hop.o2i_col_mapping()));
                left_output_index = hop.output2internal_col_mapping().try_map_all(left_output_index.into_iter()).unwrap();
                pull_up_left = true;
            (input,Some(time_col),Some(window_slide),Some(window_size),Some(window_offset))
        } else {
            old_i2new_i = old_i2new_i.union(&join.i2l_col_mapping_ignore_join_type());

            (left,None,None,None,None)
        };

        let (new_right,
            right_time_col,
            right_window_slide,
            right_window_size,
            right_window_offset
        ) =
            if let Some(hop) = right.as_logical_hop_window() &&
            right_input_index_on_condition.iter().all(|&index| hop.output_window_start_col_idx().map_or(true, |v|index!=v) && hop.output_window_end_col_idx().map_or(true, |v|index!=v)) &&
            join_type != JoinType::LeftAnti && join_type != JoinType::LeftSemi && join_type != JoinType::LeftOuter && join_type != JoinType::FullOuter {
                let (input,
                    time_col,
                    window_slide,
                    window_size,
                    window_offset,
                    _) = hop.clone().into_parts();

                old_i2new_i = old_i2new_i.union(&join.i2r_col_mapping_ignore_join_type().composite(&hop.o2i_col_mapping()).clone_with_offset(new_left.schema().len()));
                right_output_index = hop.output2internal_col_mapping().try_map_all(right_output_index.into_iter()).unwrap();
                pull_up_right = true;
                (input,Some(time_col),Some(window_slide),Some(window_size),Some(window_offset))
        } else {
            old_i2new_i = old_i2new_i.union(&join.i2r_col_mapping_ignore_join_type().clone_with_offset(new_left.schema().len()));

            (right,None,None,None,None)
        };

        if !pull_up_left && !pull_up_right {
            return None;
        }

        let new_output_index = {
            let new_right_output_len =
                if join_type == JoinType::LeftSemi || join_type == JoinType::LeftAnti {
                    0
                } else {
                    new_right.schema().len()
                };
            let new_left_output_len =
                if join_type == JoinType::RightSemi || join_type == JoinType::RightAnti {
                    0
                } else {
                    new_left.schema().len()
                };
            let mut new_output_index =
                Vec::with_capacity(left_output_index.len() + right_output_index.len());
            if !pull_up_left {
                new_output_index.extend(left_output_index.into_iter());
            } else {
                new_output_index.extend(left_output_index.into_iter().map(|idx| {
                    if idx < new_left_output_len {
                        idx
                    } else {
                        idx + new_right_output_len
                    }
                }));
            }
            if pull_up_right && pull_up_left {
                new_output_index.extend(right_output_index.into_iter().map(|idx| {
                    if idx < new_right.schema().len() {
                        idx + new_left.schema().len()
                    } else {
                        idx + new_left.schema().len() + 2
                    }
                }));
            } else {
                new_output_index.extend(
                    right_output_index
                        .into_iter()
                        .map(|idx| idx + new_left_output_len),
                );
            }
            new_output_index
        };
        let new_left_len = new_left.schema().len();
        let new_cond = on.rewrite_expr(&mut IndexRewriter::new(old_i2new_i));
        let new_join = LogicalJoin::new(new_left, new_right, join_type, new_cond);

        let new_hop = if pull_up_left && pull_up_right {
            let left_hop = LogicalHopWindow::create(
                new_join.into(),
                left_time_col.unwrap(),
                left_window_slide.unwrap(),
                left_window_size.unwrap(),
                left_window_offset.unwrap(),
            );
            LogicalHopWindow::create(
                left_hop,
                right_time_col
                    .unwrap()
                    .clone_with_offset(new_left_len as isize),
                right_window_slide.unwrap(),
                right_window_size.unwrap(),
                right_window_offset.unwrap(),
            )
        } else if pull_up_left {
            LogicalHopWindow::create(
                new_join.into(),
                left_time_col.unwrap(),
                left_window_slide.unwrap(),
                left_window_size.unwrap(),
                left_window_offset.unwrap(),
            )
        } else {
            LogicalHopWindow::create(
                new_join.into(),
                right_time_col
                    .unwrap()
                    .clone_with_offset(new_left_len as isize),
                right_window_slide.unwrap(),
                right_window_size.unwrap(),
                right_window_offset.unwrap(),
            )
        };

        Some(
            new_hop
                .as_logical_hop_window()
                .unwrap()
                .clone_with_output_indices(new_output_index)
                .into(),
        )
    }
}

impl PullUpHopRule {
    pub fn create() -> BoxedRule {
        Box::new(PullUpHopRule {})
    }
}
