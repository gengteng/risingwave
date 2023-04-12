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

use risingwave_common::types::F64;
use risingwave_expr_macro::function;

#[function("sin(float64) -> float64")]
pub fn sin_f64(input: F64) -> F64 {
    f64::sin(input.0).into()
}

#[function("cos(float64) -> float64")]
pub fn cos_f64(input: F64) -> F64 {
    f64::cos(input.0).into()
}

#[function("tan(float64) -> float64")]
pub fn tan_f64(input: F64) -> F64 {
    f64::tan(input.0).into()
}

#[function("cot(float64) -> float64")]
pub fn cot_f64(input: F64) -> F64 {
    let res = 1.0 / f64::tan(input.0);
    res.into()
}

#[function("asin(float64) -> float64")]
pub fn asin_f64(input: F64) -> F64 {
    f64::asin(input.0).into()
}

#[function("acos(float64) -> float64")]
pub fn acos_f64(input: F64) -> F64 {
    f64::acos(input.0).into()
}

#[function("atan(float64) -> float64")]
pub fn atan_f64(input: F64) -> F64 {
    f64::atan(input.0).into()
}

#[function("atan2(float64, float64) -> float64")]
pub fn atan2_f64(input_x: F64, input_y: F64) -> F64 {
    input_x.0.atan2(input_y.0).into()
}

#[function("degrees(float64) -> float64")]
pub fn degrees_f64(input: F64) -> F64 {
    input.0.to_degrees().into()
}

#[function("radians(float64) -> float64")]
pub fn radians_f64(input: F64) -> F64 {
    input.0.to_radians().into()
}

#[function("sind(float64) -> float64")]
pub fn sind_f64(input: F64) -> F64 {
    f64::sin(input.0.to_radians()).into()
}

#[function("cosd(float64) -> float64")]
pub fn cosd_f64(input: F64) -> F64 {
    f64::cos(input.0.to_radians()).into()
}

#[function("tand(float64) -> float64")]
pub fn tand_f64(input: F64) -> F64 {
    f64::tan(input.0.to_radians()).into()
}

#[function("cotd(float64) -> float64")]
pub fn cotd_f64(input: F64) -> F64 {
    let res = 1.0 / f64::tan(input.0.to_radians());
    res.into()
}

#[function("asind(float64) -> float64")]
pub fn asind_f64(input: F64) -> F64 {
    f64::asin(input.0).to_degrees().into()
}

#[function("acosd(float64) -> float64")]
pub fn acosd_f64(input: F64) -> F64 {
    f64::acos(input.0).to_degrees().into()
}

#[function("atand(float64) -> float64")]
pub fn atand_f64(input: F64) -> F64 {
    f64::atan(input.0).to_degrees().into()
}

#[function("atan2d(float64, float64) -> float64")]
pub fn atan2d_f64(input_x: F64, input_y: F64) -> F64 {
    input_x.0.atan2(input_y.0).to_degrees().into()
}

#[cfg(test)]
mod tests {
    use risingwave_common::types::F64;

    use crate::vector_op::trigonometric::*;

    /// numbers are equal within a rounding error
    fn assert_similar(lhs: F64, rhs: F64) {
        let x = F64::from(lhs.abs() - rhs.abs()).abs() <= 0.000000000000001;
        assert!(x, "{lhs} is not similar to {rhs}");
    }

    #[test]
    fn test_trigonometric_funcs() {
        // from https://en.wikipedia.org/wiki/Trigonometric_functions#Sum_and_difference_formulas
        let x = F64::from(1);
        let y = F64::from(3);
        let one = F64::from(1);
        assert_similar(
            sin_f64(x + y),
            sin_f64(x) * cos_f64(y) + cos_f64(x) * sin_f64(y),
        );
        assert_similar(
            cos_f64(x + y),
            cos_f64(x) * cos_f64(y) - sin_f64(x) * sin_f64(y),
        );
        assert_similar(
            tan_f64(x + y),
            (tan_f64(x) + tan_f64(y)) / (one - tan_f64(x) * tan_f64(y)),
        );
    }

    #[test]
    fn test_inverse_trigonometric_funcs() {
        let x = F64::from(1);
        let y = F64::from(3);
        let two = F64::from(2);
        // https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Relationships_between_trigonometric_functions_and_inverse_trigonometric_functions
        assert_similar(x, sin_f64(asin_f64(x)));
        assert_similar(x, cos_f64(acos_f64(x)));
        assert_similar(x, tan_f64(atan_f64(x)));
        // https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Two-argument_variant_of_arctangent
        assert_similar(
            atan2_f64(y, x),
            two * atan_f64(y / (F64::from(F64::from(x.powi(2) + y.powi(2)).sqrt()) + x)),
        )
    }

    #[test]
    fn test_degrees_and_radians() {
        let full_angle = F64::from(360);
        let tau = F64::from(std::f64::consts::TAU);
        assert_similar(degrees_f64(tau), full_angle);
        assert_similar(radians_f64(full_angle), tau);

        let straight_angle = F64::from(180);
        let pi = F64::from(std::f64::consts::PI);
        assert_similar(degrees_f64(pi), straight_angle);
        assert_similar(radians_f64(straight_angle), pi);

        let right_angle = F64::from(90);
        let half_pi = F64::from(std::f64::consts::PI / 2.);
        assert_similar(degrees_f64(half_pi), right_angle);
        assert_similar(radians_f64(right_angle), half_pi);

        let zero = F64::from(0);
        assert_similar(degrees_f64(zero), zero);
        assert_similar(radians_f64(zero), zero);
    }

    #[test]
    fn test_trigonometric_degree_funcs() {
        // from https://en.wikipedia.org/wiki/Trigonometric_functions#Sum_and_difference_formulas
        let x = F64::from(1.0f64.to_degrees());
        let y = F64::from(3.0f64.to_degrees());
        let one = F64::from(1);
        assert_similar(
            sind_f64(x + y),
            sind_f64(x) * cosd_f64(y) + cosd_f64(x) * sind_f64(y),
        );
        assert_similar(
            cosd_f64(x + y),
            cosd_f64(x) * cosd_f64(y) - sind_f64(x) * sind_f64(y),
        );
        assert_similar(
            tand_f64(x + y),
            (tand_f64(x) + tand_f64(y)) / (one - tand_f64(x) * tand_f64(y)),
        );
    }

    #[test]
    fn test_inverse_trigonometric_degree_funcs() {
        let x = F64::from(1);
        let y = F64::from(3);
        let two = F64::from(2);
        // https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Relationships_between_trigonometric_functions_and_inverse_trigonometric_functions
        assert_similar(x, sind_f64(asind_f64(x)));
        assert_similar(x, cosd_f64(acosd_f64(x)));
        assert_similar(x, tand_f64(atand_f64(x)));
        // https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Two-argument_variant_of_arctangent
        assert_similar(
            atan2d_f64(y, x),
            two * atand_f64(y / (F64::from(F64::from(x.powi(2) + y.powi(2)).sqrt()) + x)),
        )
    }
}
