module decode_bc3

import utils

fn get_alpha_index(alpha_indices []u16, pixel_index int) u32 {
	return utils.extract_bits_from_u16_array(alpha_indices, 3 * (15 - pixel_index), 3)
}

pub fn decode_bc3(image_data []byte, width int, height int, premultiplied bool) []u8 {
	mut rgba := []u8{len: width * height * 4, init: 0}
	height_4 := height / 4
	width_4 := width / 4
	mut offset := 0

	for h in 0 .. height_4 {
		for w in 0 .. width_4 {
			first_alpha := image_data[offset]
			second_alpha := image_data[offset + 1]
			alpha_values := utils.interpolate_alpha_values(first_alpha, second_alpha)
			alpha_indices := [
				utils.get_u16_le(image_data, offset + 6),
				utils.get_u16_le(image_data, offset + 4),
				utils.get_u16_le(image_data, offset + 2),
			]
			c0 := utils.get_u16_le(image_data, offset + 8)
			c1 := utils.get_u16_le(image_data, offset + 10)
			color_values := utils.interpolate_color_values(c0, c1, false)
			color_indices := utils.get_u32_le(image_data, offset + 12)

			for y in 0 .. 4 {
				for x in 0 .. 4 {
					pixel_index := (3 - x) + (y * 4)
					rgba_index := (h * 4 + 3 - y) * width * 4 + (w * 4 + x) * 4
					color_index := (color_indices >> (2 * (15 - pixel_index))) & 0x03
					alpha_index := get_alpha_index(alpha_indices, pixel_index)
					alpha_value := alpha_values[alpha_index]
					multiplier := if premultiplied { 255.0 / f32(alpha_value) } else { 1.0 }
					rgba[rgba_index] = utils.multiply(color_values[color_index * 4], multiplier)
					rgba[rgba_index + 1] = utils.multiply(color_values[color_index * 4 + 1], multiplier)
					rgba[rgba_index + 2] = utils.multiply(color_values[color_index * 4 + 2], multiplier)
					rgba[rgba_index + 3] = alpha_value
				}
			}
			offset += 16
		}
	}
	return rgba
}
