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

use std::any::type_name;
use std::fmt::{Debug, Write};
use std::str::FromStr;

use futures_util::FutureExt;
use itertools::Itertools;
use num_traits::ToPrimitive;
use risingwave_common::array::{
    JsonbRef, ListArray, ListRef, ListValue, StructArray, StructRef, StructValue, Utf8Array,
};
use risingwave_common::row::OwnedRow;
use risingwave_common::types::bytea::str_to_bytea;
use risingwave_common::types::struct_type::StructType;
use risingwave_common::types::to_text::ToText;
use risingwave_common::types::{
    DataType, Date, Decimal, Interval, ScalarImpl, Time, Timestamp, F32, F64,
};
use risingwave_common::util::iter_util::ZipEqFast;
use risingwave_expr_macro::{build_function, function};
use risingwave_pb::expr::expr_node::PbType;

use crate::expr::template::UnaryExpression;
use crate::expr::{build, BoxedExpression, Expression, InputRefExpression};
use crate::{ExprError, Result};

/// String literals for bool type.
///
/// See [`https://www.postgresql.org/docs/9.5/datatype-boolean.html`]
const TRUE_BOOL_LITERALS: [&str; 9] = ["true", "tru", "tr", "t", "on", "1", "yes", "ye", "y"];
const FALSE_BOOL_LITERALS: [&str; 10] = [
    "false", "fals", "fal", "fa", "f", "off", "of", "0", "no", "n",
];
const ERROR_INT_TO_TIMESTAMP: &str = "Can't cast negative integer to timestamp";

/// Converts UNIX epoch time to timestamp.
///
/// The input UNIX epoch time is interpreted as follows:
///
/// - [0, 1e11) are assumed to be in seconds.
/// - [1e11, 1e14) are assumed to be in milliseconds.
/// - [1e14, 1e17) are assumed to be in microseconds.
/// - [1e17, upper) are assumed to be in nanoseconds.
///
/// This would cause no problem for timestamp in [1973-03-03 09:46:40, 5138-11-16 09:46:40).
///
/// # Example
/// ```
/// # use risingwave_expr::vector_op::cast::i64_to_timestamp;
/// assert_eq!(
///     i64_to_timestamp(1_666_666_666).unwrap().to_string(),
///     "2022-10-25 02:57:46"
/// );
/// assert_eq!(
///     i64_to_timestamp(1_666_666_666_666).unwrap().to_string(),
///     "2022-10-25 02:57:46.666"
/// );
/// assert_eq!(
///     i64_to_timestamp(1_666_666_666_666_666).unwrap().to_string(),
///     "2022-10-25 02:57:46.666666"
/// );
/// assert_eq!(
///     i64_to_timestamp(1_666_666_666_666_666_666)
///         .unwrap()
///         .to_string(),
///     // note that we only support microseconds precision
///     "2022-10-25 02:57:46.666666"
/// );
/// ```
#[inline]
pub fn i64_to_timestamp(t: i64) -> Result<Timestamp> {
    let us = i64_to_timestamptz(t)?;
    Ok(Timestamp::from_timestamp_uncheck(
        us / 1_000_000,
        (us % 1_000_000) as u32 * 1000,
    ))
}

/// Converts UNIX epoch time to timestamp in microseconds.
///
/// The input UNIX epoch time is interpreted as follows:
///
/// - [0, 1e11) are assumed to be in seconds.
/// - [1e11, 1e14) are assumed to be in milliseconds.
/// - [1e14, 1e17) are assumed to be in microseconds.
/// - [1e17, upper) are assumed to be in nanoseconds.
///
/// This would cause no problem for timestamp in [1973-03-03 09:46:40, 5138-11-16 09:46:40).
#[inline]
pub fn i64_to_timestamptz(t: i64) -> Result<i64> {
    const E11: i64 = 100_000_000_000;
    const E14: i64 = 100_000_000_000_000;
    const E17: i64 = 100_000_000_000_000_000;
    match t {
        0..E11 => Ok(t * 1_000_000), // s
        E11..E14 => Ok(t * 1_000),   // ms
        E14..E17 => Ok(t),           // us
        E17.. => Ok(t / 1_000),      // ns
        _ => Err(ExprError::Parse(ERROR_INT_TO_TIMESTAMP.into())),
    }
}

#[function("cast(varchar) -> bytea")]
#[inline]
pub fn varchar_to_bytea(elem: &str) -> Result<Box<[u8]>> {
    str_to_bytea(elem).map_err(ExprError::Parse)
}

#[function("cast(varchar) -> *number")]
#[function("cast(varchar) -> interval")]
#[function("cast(varchar) -> jsonb")]
#[function("cast(varchar) -> date")]
#[function("cast(varchar) -> time")]
#[function("cast(varchar) -> timestamp")]
pub fn varchar_parse<T>(elem: &str) -> Result<T>
where
    T: FromStr,
    <T as FromStr>::Err: std::fmt::Display,
{
    elem.trim()
        .parse()
        .map_err(|_| ExprError::Parse(type_name::<T>().into()))
}

// Define the cast function to primitive types.
//
// Due to the orphan rule, some data can't implement `TryFrom` trait for basic type.
// We can only use [`ToPrimitive`] trait.
//
// Note: this might be lossy according to the docs from [`ToPrimitive`]:
// > On the other hand, conversions with possible precision loss or truncation
// are admitted, like an `f32` with a decimal part to an integer type, or
// even a large `f64` saturating to `f32` infinity.

#[function("cast(float32) -> int16")]
#[function("cast(float64) -> int16")]
pub fn to_i16<T: ToPrimitive + Debug>(elem: T) -> Result<i16> {
    elem.to_i16().ok_or(ExprError::CastOutOfRange("i16"))
}

#[function("cast(float32) -> int32")]
#[function("cast(float64) -> int32")]
pub fn to_i32<T: ToPrimitive + Debug>(elem: T) -> Result<i32> {
    elem.to_i32().ok_or(ExprError::CastOutOfRange("i32"))
}

#[function("cast(float32) -> int64")]
#[function("cast(float64) -> int64")]
pub fn to_i64<T: ToPrimitive + Debug>(elem: T) -> Result<i64> {
    elem.to_i64().ok_or(ExprError::CastOutOfRange("i64"))
}

#[function("cast(int32) -> float32")]
#[function("cast(int64) -> float32")]
#[function("cast(float64) -> float32")]
#[function("cast(decimal) -> float32")]
pub fn to_f32<T: ToPrimitive + Debug>(elem: T) -> Result<F32> {
    elem.to_f32()
        .map(Into::into)
        .ok_or(ExprError::CastOutOfRange("f32"))
}

#[function("cast(decimal) -> float64")]
pub fn to_f64<T: ToPrimitive + Debug>(elem: T) -> Result<F64> {
    elem.to_f64()
        .map(Into::into)
        .ok_or(ExprError::CastOutOfRange("f64"))
}

// In postgresSql, the behavior of casting decimal to integer is rounding.
// We should write them separately
#[function("cast(decimal) -> int16")]
pub fn dec_to_i16(elem: Decimal) -> Result<i16> {
    to_i16(elem.round_dp(0))
}

#[function("cast(decimal) -> int32")]
pub fn dec_to_i32(elem: Decimal) -> Result<i32> {
    to_i32(elem.round_dp(0))
}

#[function("cast(decimal) -> int64")]
pub fn dec_to_i64(elem: Decimal) -> Result<i64> {
    to_i64(elem.round_dp(0))
}

#[function("cast(jsonb) -> boolean")]
pub fn jsonb_to_bool(v: JsonbRef<'_>) -> Result<bool> {
    v.as_bool().map_err(|e| ExprError::Parse(e.into()))
}

#[function("cast(jsonb) -> decimal")]
pub fn jsonb_to_dec(v: JsonbRef<'_>) -> Result<Decimal> {
    v.as_number()
        .map_err(|e| ExprError::Parse(e.into()))
        .map(Into::into)
}

/// Similar to and an result of [`define_cast_to_primitive`] macro above.
/// If that was implemented as a trait to cast from `f64`, this could also call them via trait
/// rather than macro.
///
/// Note that PostgreSQL casts JSON numbers from arbitrary precision `numeric` but we use `f64`.
/// This is less powerful but still meets RFC 8259 interoperability.
macro_rules! define_jsonb_to_number {
    ($ty:ty, $sig:literal) => {
        define_jsonb_to_number! { $ty, $ty, $sig }
    };
    ($ty:ty, $wrapper_ty:ty, $sig:literal) => {
        paste::paste! {
            #[function($sig)]
            pub fn [<jsonb_to_ $ty>](v: JsonbRef<'_>) -> Result<$wrapper_ty> {
                v.as_number().map_err(|e| ExprError::Parse(e.into())).and_then([<to_ $ty>])
            }
        }
    };
}
define_jsonb_to_number! { i16, "cast(jsonb) -> int16" }
define_jsonb_to_number! { i32, "cast(jsonb) -> int32" }
define_jsonb_to_number! { i64, "cast(jsonb) -> int64" }
define_jsonb_to_number! { f32, F32, "cast(jsonb) -> float32" }
define_jsonb_to_number! { f64, F64, "cast(jsonb) -> float64" }

/// In `PostgreSQL`, casting from timestamp to date discards the time part.
#[function("cast(timestamp) -> date")]
pub fn timestamp_to_date(elem: Timestamp) -> Date {
    Date(elem.0.date())
}

/// In `PostgreSQL`, casting from timestamp to time discards the date part.
#[function("cast(timestamp) -> time")]
pub fn timestamp_to_time(elem: Timestamp) -> Time {
    Time(elem.0.time())
}

/// In `PostgreSQL`, casting from interval to time discards the days part.
#[function("cast(interval) -> time")]
pub fn interval_to_time(elem: Interval) -> Time {
    let usecs = elem.get_usecs_of_day();
    let secs = (usecs / 1_000_000) as u32;
    let nano = (usecs % 1_000_000 * 1000) as u32;
    Time::from_num_seconds_from_midnight_uncheck(secs, nano)
}

#[function("cast(boolean) -> int32")]
#[function("cast(int32) -> int16")]
#[function("cast(int64) -> int16")]
#[function("cast(int64) -> int32")]
#[function("cast(int64) -> float64")]
pub fn try_cast<T1, T2>(elem: T1) -> Result<T2>
where
    T1: TryInto<T2> + std::fmt::Debug + Copy,
    <T1 as TryInto<T2>>::Error: std::fmt::Display,
{
    elem.try_into()
        .map_err(|_| ExprError::CastOutOfRange(std::any::type_name::<T2>()))
}

#[function("cast(int16) -> int32")]
#[function("cast(int16) -> int64")]
#[function("cast(int16) -> float32")]
#[function("cast(int16) -> float64")]
#[function("cast(int16) -> decimal")]
#[function("cast(int32) -> int64")]
#[function("cast(int32) -> float64")]
#[function("cast(int32) -> decimal")]
#[function("cast(int64) -> decimal")]
#[function("cast(float32) -> float64")]
#[function("cast(float32) -> decimal")]
#[function("cast(float64) -> decimal")]
#[function("cast(date) -> timestamp")]
#[function("cast(time) -> interval")]
#[function("cast(varchar) -> varchar")]
pub fn cast<T1, T2>(elem: T1) -> T2
where
    T1: Into<T2>,
{
    elem.into()
}

#[function("cast(varchar) -> boolean")]
pub fn varchar_to_bool(input: &str) -> Result<bool> {
    let trimmed_input = input.trim();
    if TRUE_BOOL_LITERALS
        .iter()
        .any(|s| s.eq_ignore_ascii_case(trimmed_input))
    {
        Ok(true)
    } else if FALSE_BOOL_LITERALS
        .iter()
        .any(|s| trimmed_input.eq_ignore_ascii_case(s))
    {
        Ok(false)
    } else {
        Err(ExprError::Parse("Invalid bool".into()))
    }
}

#[function("cast(int32) -> boolean")]
pub fn int32_to_bool(input: i32) -> Result<bool> {
    Ok(input != 0)
}

// For most of the types, cast them to varchar is similar to return their text format.
// So we use this function to cast type to varchar.
#[function("cast(*number) -> varchar")]
#[function("cast(time) -> varchar")]
#[function("cast(date) -> varchar")]
#[function("cast(interval) -> varchar")]
#[function("cast(timestamp) -> varchar")]
#[function("cast(jsonb) -> varchar")]
#[function("cast(list) -> varchar")]
pub fn general_to_text(elem: impl ToText, mut writer: &mut dyn Write) -> Result<()> {
    elem.write(&mut writer).unwrap();
    Ok(())
}

#[function("cast(boolean) -> varchar")]
pub fn bool_to_varchar(input: bool, writer: &mut dyn Write) -> Result<()> {
    writer
        .write_str(if input { "true" } else { "false" })
        .unwrap();
    Ok(())
}

/// `bool_out` is different from `general_to_string<bool>` to produce a single char. `PostgreSQL`
/// uses different variants of bool-to-string in different situations.
#[function("bool_out(boolean) -> varchar")]
pub fn bool_out(input: bool, writer: &mut dyn Write) -> Result<()> {
    writer.write_str(if input { "t" } else { "f" }).unwrap();
    Ok(())
}

/// A lite version of casting from string to target type. Used by frontend to handle types that have
/// to be created by casting.
///
/// For example, the user can input `1` or `true` directly, but they have to use
/// `'2022-01-01'::date`.
pub fn literal_parsing(
    t: &DataType,
    s: &str,
) -> std::result::Result<ScalarImpl, Option<ExprError>> {
    let scalar = match t {
        DataType::Boolean => varchar_to_bool(s)?.into(),
        DataType::Serial => return Err(None),
        DataType::Varchar => return Err(None),
        // Not processing list or struct literal right now. Leave it for later phase (normal backend
        // evaluation).
        DataType::List { .. } => return Err(None),
        DataType::Struct(_) => return Err(None),
        DataType::Jsonb => return Err(None),
        // NOTE: The literal parse of other type is same as parse for text format.
        // NOTE: We only handle the case with timezone here, and leave the implicit session timezone
        // case for later phase.
        // NOTE: `text_to_scalar` will not trim the string before parse it so we need to trim before
        // call it.
        other => other
            .text_instance(s.trim())
            .map_err(|err| ExprError::Parse(err.into()))?,
    };
    Ok(scalar)
}

#[build_function("cast(varchar) -> list")]
fn build_cast_str_to_list(
    return_type: DataType,
    children: Vec<BoxedExpression>,
) -> Result<BoxedExpression> {
    let elem_type = match &return_type {
        DataType::List { datatype } => (**datatype).clone(),
        _ => panic!("expected list type"),
    };
    let child = children.into_iter().next().unwrap();
    Ok(Box::new(UnaryExpression::<Utf8Array, ListArray, _>::new(
        child,
        return_type,
        move |x| varchar_to_list(x, &elem_type),
    )))
}

fn varchar_to_list(input: &str, target_elem_type: &DataType) -> Result<ListValue> {
    let parse = |target_type: &DataType, str: &str| {
        let cast = build(
            PbType::Cast,
            target_type.clone(),
            vec![InputRefExpression::new(DataType::Varchar, 0).boxed()],
        )
        .unwrap();
        cast.eval_row(&OwnedRow::new(vec![Some(str.to_string().into())])) // TODO: optimize
            .now_or_never()
            .unwrap()
            .map_err(|err| err.to_string())
    };
    ListValue::str_to_list(input, target_elem_type, parse)
        .map_err(|err| ExprError::Parse(err.into()))
}

#[build_function("cast(list) -> list")]
fn build_cast_list_to_list(
    return_type: DataType,
    children: Vec<BoxedExpression>,
) -> Result<BoxedExpression> {
    let child = children.into_iter().next().unwrap();
    let source_elem_type = match child.return_type() {
        DataType::List { datatype } => (*datatype).clone(),
        _ => panic!("expected list type"),
    };
    let target_elem_type = match &return_type {
        DataType::List { datatype } => (**datatype).clone(),
        _ => panic!("expected list type"),
    };
    Ok(Box::new(UnaryExpression::<ListArray, ListArray, _>::new(
        child,
        return_type,
        move |x| list_cast(x, &source_elem_type, &target_elem_type),
    )))
}

/// Cast array with `source_elem_type` into array with `target_elem_type` by casting each element.
fn list_cast(
    input: ListRef<'_>,
    source_elem_type: &DataType,
    target_elem_type: &DataType,
) -> Result<ListValue> {
    let cast = build(
        PbType::Cast,
        target_elem_type.clone(),
        vec![InputRefExpression::new(source_elem_type.clone(), 0).boxed()],
    )
    .unwrap();
    let elements = input.values_ref();
    let mut values = Vec::with_capacity(elements.len());
    for item in elements {
        let v = cast
            .eval_row(&OwnedRow::new(vec![item.map(|s| s.into_scalar_impl())])) // TODO: optimize
            .now_or_never()
            .unwrap()?;
        values.push(v);
    }
    Ok(ListValue::new(values))
}

#[build_function("cast(struct) -> struct")]
fn build_cast_struct_to_struct(
    return_type: DataType,
    children: Vec<BoxedExpression>,
) -> Result<BoxedExpression> {
    let child = children.into_iter().next().unwrap();
    let source_elem_type = match child.return_type() {
        DataType::Struct(s) => (*s).clone(),
        _ => panic!("expected struct type"),
    };
    let target_elem_type = match &return_type {
        DataType::Struct(s) => (**s).clone(),
        _ => panic!("expected struct type"),
    };
    Ok(Box::new(
        UnaryExpression::<StructArray, StructArray, _>::new(child, return_type, move |x| {
            struct_cast(x, &source_elem_type, &target_elem_type)
        }),
    ))
}

/// Cast struct of `source_elem_type` to `target_elem_type` by casting each element.
fn struct_cast(
    input: StructRef<'_>,
    source_elem_type: &StructType,
    target_elem_type: &StructType,
) -> Result<StructValue> {
    let fields = (input.fields_ref().into_iter())
        .zip_eq_fast(source_elem_type.fields.iter())
        .zip_eq_fast(target_elem_type.fields.iter())
        .map(|((datum_ref, source_field_type), target_field_type)| {
            if source_field_type == target_field_type {
                return Ok(datum_ref.map(|scalar_ref| scalar_ref.into_scalar_impl()));
            }
            let cast = build(
                PbType::Cast,
                target_field_type.clone(),
                vec![InputRefExpression::new(source_field_type.clone(), 0).boxed()],
            )
            .unwrap();
            let value = match datum_ref {
                Some(scalar_ref) => cast
                    .eval_row(&OwnedRow::new(vec![Some(scalar_ref.into_scalar_impl())]))
                    .now_or_never()
                    .unwrap()?,
                None => None,
            };
            Ok(value) as Result<_>
        })
        .try_collect()?;
    Ok(StructValue::new(fields))
}

#[cfg(test)]
mod tests {

    use num_traits::FromPrimitive;
    use risingwave_common::types::Scalar;

    use super::*;

    #[test]
    fn integer_cast_to_bool() {
        use super::*;
        assert!(int32_to_bool(32).unwrap());
        assert!(int32_to_bool(-32).unwrap());
        assert!(!int32_to_bool(0).unwrap());
    }

    #[test]
    fn number_to_string() {
        use super::*;

        macro_rules! test {
            ($fn:ident($value:expr), $right:literal) => {
                let mut writer = String::new();
                $fn($value, &mut writer).unwrap();
                assert_eq!(writer, $right);
            };
        }

        test!(bool_to_varchar(true), "true");
        test!(bool_to_varchar(true), "true");
        test!(bool_to_varchar(false), "false");

        test!(general_to_text(32), "32");
        test!(general_to_text(-32), "-32");
        test!(general_to_text(i32::MIN), "-2147483648");
        test!(general_to_text(i32::MAX), "2147483647");

        test!(general_to_text(i16::MIN), "-32768");
        test!(general_to_text(i16::MAX), "32767");

        test!(general_to_text(i64::MIN), "-9223372036854775808");
        test!(general_to_text(i64::MAX), "9223372036854775807");

        test!(general_to_text(F64::from(32.12)), "32.12");
        test!(general_to_text(F64::from(-32.14)), "-32.14");

        test!(general_to_text(F32::from(32.12_f32)), "32.12");
        test!(general_to_text(F32::from(-32.14_f32)), "-32.14");

        test!(general_to_text(Decimal::from_f64(1.222).unwrap()), "1.222");

        test!(general_to_text(Decimal::NaN), "NaN");
    }

    #[test]
    fn temporal_cast() {
        assert_eq!(
            timestamp_to_date(Timestamp::from_str("1999-01-08 04:02").unwrap()),
            Date::from_str("1999-01-08").unwrap(),
        );
        assert_eq!(
            timestamp_to_time(Timestamp::from_str("1999-01-08 04:02").unwrap()),
            Time::from_str("04:02").unwrap(),
        );
        assert_eq!(
            interval_to_time(Interval::from_month_day_usec(1, 2, 61000003)),
            Time::from_str("00:01:01.000003").unwrap(),
        );
        assert_eq!(
            interval_to_time(Interval::from_month_day_usec(0, 0, -61000003)),
            Time::from_str("23:58:58.999997").unwrap(),
        );
    }

    #[test]
    fn test_list_cast() {
        let list123 = ListValue::new(vec![
            Some(1.to_scalar_value()),
            Some(2.to_scalar_value()),
            Some(3.to_scalar_value()),
        ]);
        let nested_list123 = ListValue::new(vec![Some(ScalarImpl::List(list123))]);
        let nested_list445566 = ListValue::new(vec![Some(ScalarImpl::List(ListValue::new(vec![
            Some(44.to_scalar_value()),
            Some(55.to_scalar_value()),
            Some(66.to_scalar_value()),
        ])))]);
        // Cast previous double nested lists to double nested varchar lists
        let double_nested_varchar_list123_445566 = ListValue::new(vec![
            Some(ScalarImpl::List(
                list_cast(
                    ListRef::ValueRef {
                        val: &nested_list123,
                    },
                    &DataType::List {
                        datatype: Box::new(DataType::Int32),
                    },
                    &DataType::List {
                        datatype: Box::new(DataType::Varchar),
                    },
                )
                .unwrap(),
            )),
            Some(ScalarImpl::List(
                list_cast(
                    ListRef::ValueRef {
                        val: &nested_list445566,
                    },
                    &DataType::List {
                        datatype: Box::new(DataType::Int32),
                    },
                    &DataType::List {
                        datatype: Box::new(DataType::Varchar),
                    },
                )
                .unwrap(),
            )),
        ]);

        // Double nested Varchar List
        assert_eq!(
            varchar_to_list(
                "{{{1, 2, 3}}, {{44, 55, 66}}}",
                &DataType::List {
                    datatype: Box::new(DataType::List {
                        datatype: Box::new(DataType::Varchar)
                    })
                }
            )
            .unwrap(),
            double_nested_varchar_list123_445566
        );
    }

    #[test]
    fn test_struct_cast() {
        assert_eq!(
            struct_cast(
                StructValue::new(vec![
                    Some("1".into()),
                    Some(F32::from(0.0).to_scalar_value()),
                ])
                .as_scalar_ref(),
                &StructType::new(vec![
                    (DataType::Varchar, "a".to_string()),
                    (DataType::Float32, "b".to_string()),
                ]),
                &StructType::new(vec![
                    (DataType::Int32, "a".to_string()),
                    (DataType::Int32, "b".to_string()),
                ])
            )
            .unwrap(),
            StructValue::new(vec![
                Some(1i32.to_scalar_value()),
                Some(0i32.to_scalar_value()),
            ])
        );
    }
}
