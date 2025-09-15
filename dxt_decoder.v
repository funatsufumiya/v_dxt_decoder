module dxt_decoder

pub enum DxtFormat {
	dxt1
	dxt2
	dxt3
	dxt4
	dxt5
}

pub fn decode(image_data []u8, width int, height int, format DxtFormat) ![]u8 {
	match format {
		.dxt1 {
			return decode_bc1(image_data, width, height)
		}
		.dxt2 {
			return decode_bc2(image_data, width, height, true)
		}
		.dxt3 {
			return decode_bc2(image_data, width, height, false)
		}
		.dxt4 {
			return decode_bc3(image_data, width, height, true)
		}
		.dxt5 {
			return decode_bc3(image_data, width, height, false)
		}
	}
	return error('Unknown DXT format')
}