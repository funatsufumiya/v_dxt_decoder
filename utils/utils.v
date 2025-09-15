module utils

pub fn lerp(v1 f32, v2 f32, r f32) f32 {
	return v1 * (1.0 - r) + v2 * r
}

pub fn convert_565_to_rgb(val u16) [3]u8 {
	r := ((val >> 11) & 31)
	g := ((val >> 5) & 63)
	b := (val & 31)
	return [
		u8(f32(r) * (255.0 / 31.0) + 0.5),
		u8(f32(g) * (255.0 / 63.0) + 0.5),
		u8(f32(b) * (255.0 / 31.0) + 0.5),
	]
}

pub fn get_u16_le(data []byte, offset int) u16 {
	return u16(data[offset]) | (u16(data[offset+1]) << 8)
}

pub fn get_u32_le(data []byte, offset int) u32 {
	return u32(data[offset]) | (u32(data[offset+1]) << 8) | (u32(data[offset+2]) << 16) | (u32(data[offset+3]) << 24)
}

pub fn extract_bits_from_u16_array(array []u16, shift int, length int) u32 {
	height := array.len
	heightm1 := height - 1
	width := 16
	row_s := shift / width
	row_e := (shift + length - 1) / width
	if row_s == row_e {
		shift_s := shift % width
		return (array[heightm1 - row_s] >> shift_s) & ((1 << length) - 1)
	} else {
		shift_s := shift % width
		shift_e := width - shift_s
		mut result := (array[heightm1 - row_s] >> shift_s) & ((1 << length) - 1)
		result += (array[heightm1 - row_e] & ((1 << (length - shift_e)) - 1)) << shift_e
		return result
	}
}

pub fn interpolate_color_values(first_val u16, second_val u16, is_dxt1 bool) []u8 {
	first_color := convert_565_to_rgb(first_val)
	second_color := convert_565_to_rgb(second_val)
	mut color_values := []u8{}
	color_values << first_color
	color_values << 255
	color_values << second_color
	color_values << 255
	if is_dxt1 && first_val <= second_val {
		color_values << u8((first_color[0] + second_color[0]) / 2)
		color_values << u8((first_color[1] + second_color[1]) / 2)
		color_values << u8((first_color[2] + second_color[2]) / 2)
		color_values << 255
		color_values << [u8(0), u8(0), u8(0), u8(0)]
	} else {
		color_values << u8(lerp(first_color[0], second_color[0], 1.0/3.0))
		color_values << u8(lerp(first_color[1], second_color[1], 1.0/3.0))
		color_values << u8(lerp(first_color[2], second_color[2], 1.0/3.0))
		color_values << 255
		color_values << u8(lerp(first_color[0], second_color[0], 2.0/3.0))
		color_values << u8(lerp(first_color[1], second_color[1], 2.0/3.0))
		color_values << u8(lerp(first_color[2], second_color[2], 2.0/3.0))
		color_values << 255
	}
	return color_values
}

pub fn interpolate_alpha_values(first_val u8, second_val u8) []u8 {
	mut alpha_values := [first_val, second_val]
	if first_val > second_val {
		for i in 1 .. 7 {
			alpha_values << u8(f32(first_val) * (1.0 - f32(i)/7.0) + f32(second_val) * (f32(i)/7.0))
		}
	} else {
		for i in 1 .. 5 {
			alpha_values << u8(f32(first_val) * (1.0 - f32(i)/5.0) + f32(second_val) * (f32(i)/5.0))
		}
		alpha_values << 0
		alpha_values << 255
	}
	return alpha_values
}

pub fn multiply(component u8, multiplier f32) u8 {
	if !isfinite(multiplier) || multiplier == 0.0 {
		return 0
	}
	return u8(f32(component) * multiplier + 0.5)
}
