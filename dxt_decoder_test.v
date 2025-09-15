module main

import dxt_decoder

fn test_decode_dxt1() {
	data := []u8{len: 8, init: 0}
	result := dxt_decoder.decode(data, 4, 4, .dxt1) or {
		panic('decode failed')
	}
	assert result.len == 4 * 4 * 4
}

fn test_decode_dxt3() {
	data := []u8{len: 16, init: 0}
	result := dxt_decoder.decode(data, 4, 4, .dxt3) or {
		panic('decode failed')
	}
	assert result.len == 4 * 4 * 4
}

fn test_decode_dxt5() {
	data := []u8{len: 16, init: 0}
	result := dxt_decoder.decode(data, 4, 4, .dxt5) or {
		panic('decode failed')
	}
	assert result.len == 4 * 4 * 4
}

fn main() {
	test_decode_dxt1()
	test_decode_dxt3()
	test_decode_dxt5()
	println('All DXT decode tests passed.')
}
