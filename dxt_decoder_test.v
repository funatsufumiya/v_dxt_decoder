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

fn test_dxt1_solid_color() {
	data := [
		u8(0x1f), u8(0x00),
		u8(0x1f), u8(0x00),
		u8(0x00), u8(0x00), u8(0x00), u8(0x00)
	]
	result := dxt_decoder.decode(data, 4, 4, .dxt1) or {
		panic('decode failed')
	}
	assert result.len == 4 * 4 * 4
	for i in 0 .. 16 {
		r := result[i*4+0]
		g := result[i*4+1]
		b := result[i*4+2]
		a := result[i*4+3]
		assert r == 0
		assert g == 0
		assert b == 255
		assert a == 255
	}
}

fn test_dxt3_alpha_all_zero() {
	data := [
		u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00),
		u8(0x00), u8(0xf8), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00)
	]
	result := dxt_decoder.decode(data, 4, 4, .dxt3) or {
		panic('decode failed')
	}
	assert result.len == 4 * 4 * 4
	for i in 0 .. 16 {
		a := result[i*4+3]
		assert a == 0
	}
}

fn test_dxt3_alpha_all_opaque() {
	data := [
		u8(0xff), u8(0xff), u8(0xff), u8(0xff), u8(0xff), u8(0xff), u8(0xff), u8(0xff),
		u8(0x00), u8(0xf8), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00)
	]
	result := dxt_decoder.decode(data, 4, 4, .dxt3) or {
		panic('decode failed')
	}
	assert result.len == 4 * 4 * 4
	for i in 0 .. 16 {
		a := result[i*4+3]
		assert a == 255
	}
}