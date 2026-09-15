module auto

fn test_from_byte_lowercase_letters() {
	for c in 'abcdefghijklmnopqrstuvwxyz' {
		_, mod := KeyCode.from_byte(c) or { panic('missing mapping for ${c:c}') }
		assert !mod.has(.shift)
	}
}

fn test_from_byte_uppercase_letters_need_shift() {
	for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' {
		_, mod := KeyCode.from_byte(c) or { panic('missing mapping for ${c:c}') }
		assert mod.has(.shift)
	}
}

fn test_from_byte_digits() {
	for c in '0123456789' {
		KeyCode.from_byte(c) or { panic('missing mapping for ${c:c}') }
	}
}

fn test_from_byte_symbols_need_shift() {
	for c in ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '{', '}', '|', ':', '"',
		'<', '>', '?', '~'] {
		_, mod := KeyCode.from_byte(c[0]) or { panic('missing mapping for ${c}') }
		assert mod.has(.shift)
	}
}

fn test_from_byte_known_unshifted_symbols() {
	for c in [';', ',', '.', '/', '\\', "'", '-', '=', ' '] {
		KeyCode.from_byte(c[0]) or { panic('missing mapping for ${c}') }
	}
}

fn test_from_byte_control_characters() {
	code, _ := KeyCode.from_byte(`\n`) or { panic('missing newline mapping') }
	assert code == .return
	code2, _ := KeyCode.from_byte(`\t`) or { panic('missing tab mapping') }
	assert code2 == .tab
}

fn test_from_byte_rejects_unknown() {
	if _, _ := KeyCode.from_byte(u8(1)) {
		assert false
	}
	if _, _ := KeyCode.from_byte(u8(127)) {
		assert false
	}
}

fn test_keymodifier_flags() {
	mut mod := KeyModifier.zero()
	assert mod.is_empty()
	mod.set(.shift)
	assert mod.has(.shift)
	assert !mod.has(.ctrl)
	mod.set(.ctrl | .alt)
	assert mod.all(.shift | .ctrl | .alt)
}

fn test_keycode_to_evdev_mapping() {
	assert keycode_to_evdev(.a) == 30
	assert keycode_to_evdev(.q) == 16
	assert keycode_to_evdev(.z) == 44
	assert keycode_to_evdev(._1) == 2
	assert keycode_to_evdev(._0) == 11
	assert keycode_to_evdev(.space) == 57
	assert keycode_to_evdev(.return) == 28
	assert keycode_to_evdev(.escape) == 1
	assert keycode_to_evdev(.left_shift) == 42
	assert keycode_to_evdev(.f1) == 59
	assert keycode_to_evdev(.f12) == 88
	assert keycode_to_evdev(.left_arrow) == 105
	assert keycode_to_evdev(.delete) == 111
}
