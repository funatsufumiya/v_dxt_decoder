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

fn test_dxt5_alpha_all_zero_rgb_check_first_pixel() {
	// DXT5: 8 bytes alpha, 8 bytes color block (same as DXT1)
	// alpha: all 0 (min=max=0, all indices 0)
	data := [
		u8(0x00), u8(0x00), // alpha0=0, alpha1=0
		u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), // alpha indices all 0
		u8(0x1f), u8(0x00), // color0: 0x001f (B=31,G=0,R=0) => (0,0,255)
		u8(0x1f), u8(0x00), // color1: 0x001f (same)
		u8(0x00), u8(0x00), u8(0x00), u8(0x00) // color indices all 0
	]
	result := dxt_decoder.decode(data, 4, 4, .dxt5) or {
		panic('decode failed')
	}
	assert result.len == 4 * 4 * 4
	for i in 0 .. 16 {
		a := result[i*4+3]
		assert a == 0
	}
	r := result[0]
	g := result[1]
	b := result[2]
	assert r == 0
	assert g == 0
	assert b == 255
}

fn test_dxt5_alpha_all_opaque_rgb_check_first_pixel() {
	// DXT5: 8 bytes alpha, 8 bytes color block (same as DXT1)
	// alpha: all 255 (min=255,max=255, all indices 0)
	data := [
		u8(0xff), u8(0xff), // alpha0=255, alpha1=255
		u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), // alpha indices all 0
		u8(0x1f), u8(0x00), // color0: 0x001f (B=31,G=0,R=0) => (0,0,255)
		u8(0x1f), u8(0x00), // color1: 0x001f (same)
		u8(0x00), u8(0x00), u8(0x00), u8(0x00) // color indices all 0
	]
	result := dxt_decoder.decode(data, 4, 4, .dxt5) or {
		panic('decode failed')
	}
	assert result.len == 4 * 4 * 4
	for i in 0 .. 16 {
		a := result[i*4+3]
		assert a == 255
	}
	r := result[0]
	g := result[1]
	b := result[2]
	assert r == 0
	assert g == 0
	assert b == 255
}