module auto

import time

// vfmt off
const keycode_a             = $if macos { 0 }   $else { 0x41 }
const keycode_b             = $if macos { 11 }  $else { 0x42 }
const keycode_c             = $if macos { 8 }   $else { 0x43 }
const keycode_d             = $if macos { 2 }   $else { 0x44 }
const keycode_e             = $if macos { 14 }  $else { 0x45 }
const keycode_f             = $if macos { 3 }   $else { 0x46 }
const keycode_g             = $if macos { 5 }   $else { 0x47 }
const keycode_h             = $if macos { 4 }   $else { 0x48 }
const keycode_i             = $if macos { 34 }  $else { 0x49 }
const keycode_j             = $if macos { 38 }  $else { 0x4A }
const keycode_k             = $if macos { 40 }  $else { 0x4B }
const keycode_l             = $if macos { 37 }  $else { 0x4C }
const keycode_m             = $if macos { 46 }  $else { 0x4D }
const keycode_n             = $if macos { 45 }  $else { 0x4E }
const keycode_o             = $if macos { 31 }  $else { 0x4F }
const keycode_p             = $if macos { 35 }  $else { 0x50 }
const keycode_q             = $if macos { 12 }  $else { 0x51 }
const keycode_r             = $if macos { 15 }  $else { 0x52 }
const keycode_s             = $if macos { 1 }   $else { 0x53 }
const keycode_t             = $if macos { 17 }  $else { 0x54 }
const keycode_u             = $if macos { 32 }  $else { 0x55 }
const keycode_v             = $if macos { 9 }   $else { 0x56 }
const keycode_w             = $if macos { 13 }  $else { 0x57 }
const keycode_x             = $if macos { 7 }   $else { 0x58 }
const keycode_y             = $if macos { 16 }  $else { 0x59 }
const keycode_z             = $if macos { 6 }   $else { 0x5A }
const keycode_0             = $if macos { 29 }  $else { 0x30 }
const keycode_1             = $if macos { 18 }  $else { 0x31 }
const keycode_2             = $if macos { 19 }  $else { 0x32 }
const keycode_3             = $if macos { 20 }  $else { 0x33 }
const keycode_4             = $if macos { 21 }  $else { 0x34 }
const keycode_5             = $if macos { 23 }  $else { 0x35 }
const keycode_6             = $if macos { 22 }  $else { 0x36 }
const keycode_7             = $if macos { 26 }  $else { 0x37 }
const keycode_8             = $if macos { 28 }  $else { 0x38 }
const keycode_9             = $if macos { 25 }  $else { 0x39 }
const keycode_space         = $if macos { 49 }  $else { 0x20 }
const keycode_semicolon     = $if macos { 41 }  $else $if windows { 0xBA } $else { 0x003B }
const keycode_comma         = $if macos { 43 }  $else $if windows { 0xBC } $else { 0x002C }
const keycode_period        = $if macos { 47 }  $else $if windows { 0xBE } $else { 0x002E }
const keycode_slash         = $if macos { 44 }  $else $if windows { 0xBF } $else { 0x002F }
const keycode_backtick      = $if macos { 50 }  $else $if windows { 0xC0 } $else { 0x0060 }
const keycode_left_bracket  = $if macos { 33 }  $else $if windows { 0xDB } $else { 0x005B }
const keycode_right_bracket = $if macos { 30 }  $else $if windows { 0xDD } $else { 0x005D }
const keycode_backslash     = $if macos { 42 }  $else $if windows { 0xDC } $else { 0x005C }
const keycode_quote         = $if macos { 39 }  $else $if windows { 0xDE } $else { 0x0027 }
const keycode_hyphen        = $if macos { 27 }  $else $if windows { 0xBD } $else { 0x002D }
const keycode_equals        = $if macos { 24 }  $else $if windows { 0xBB } $else { 0x003D }
const keycode_return        = $if macos { 36 }  $else $if windows { 0x0D } $else { 0xFF0D }
const keycode_backspace     = $if macos { 51 }  $else $if windows { 0x08 } $else { 0xFF08 }
const keycode_tab           = $if macos { 48 }  $else $if windows { 0x09 } $else { 0xFF09 }
const keycode_left_shift    = $if macos { 56 }  $else $if windows { 0x10 } $else { 0xFFE1 }
const keycode_right_shift   = $if macos { 60 }  $else $if windows { 0xA1 } $else { 0xFFE2 }
const keycode_left_ctrl     = $if macos { 59 }  $else $if windows { 0x11 } $else { 0xFFE3 }
const keycode_right_ctrl    = $if macos { 62 }  $else $if windows { 0xA3 } $else { 0xFFE4 }
const keycode_left_alt      = $if macos { 58 }  $else $if windows { 0x12 } $else { 0xFFE9 }
const keycode_right_alt     = $if macos { 61 }  $else $if windows { 0xA5 } $else { 0xFFEA }
const keycode_escape        = $if macos { 53 }  $else $if windows { 0x1B } $else { 0xFF1B }
const keycode_f1            = $if macos { 122 } $else $if windows { 0x70 } $else { 0xFFBE }
const keycode_f2            = $if macos { 120 } $else $if windows { 0x71 } $else { 0xFFBF }
const keycode_f3            = $if macos { 99 }  $else $if windows { 0x72 } $else { 0xFFC0 }
const keycode_f4            = $if macos { 118 } $else $if windows { 0x73 } $else { 0xFFC1 }
const keycode_f5            = $if macos { 96 }  $else $if windows { 0x74 } $else { 0xFFC2 }
const keycode_f6            = $if macos { 97 }  $else $if windows { 0x75 } $else { 0xFFC3 }
const keycode_f7            = $if macos { 98 }  $else $if windows { 0x76 } $else { 0xFFC4 }
const keycode_f8            = $if macos { 100 } $else $if windows { 0x77 } $else { 0xFFC5 }
const keycode_f9            = $if macos { 101 } $else $if windows { 0x78 } $else { 0xFFC6 }
const keycode_f10           = $if macos { 109 } $else $if windows { 0x79 } $else { 0xFFC7 }
const keycode_f11           = $if macos { 103 } $else $if windows { 0x7A } $else { 0xFFC8 }
const keycode_f12           = $if macos { 111 } $else $if windows { 0x7B } $else { 0xFFC9 }
const keycode_left_arrow    = $if macos { 123 } $else $if windows { 0x25 } $else { 0xFF51 }
const keycode_right_arrow   = $if macos { 124 } $else $if windows { 0x27 } $else { 0xFF53 }
const keycode_up_arrow      = $if macos { 126 } $else $if windows { 0x26 } $else { 0xFF52 }
const keycode_down_arrow    = $if macos { 125 } $else $if windows { 0x28 } $else { 0xFF54 }
const keycode_delete        = $if macos { 117 } $else $if windows { 0x2E } $else { 0xFFFF }
// vfmt on

// KeyModifier is a key which can be pressed in combination with another key.
@[flag]
pub enum KeyModifier {
	shift
	ctrl
	alt
}

// KeyCode is a key on a keyboard.
@[_allow_multiple_values]
pub enum KeyCode {
	a             = keycode_a
	b             = keycode_b
	c             = keycode_c
	d             = keycode_d
	e             = keycode_e
	f             = keycode_f
	g             = keycode_g
	h             = keycode_h
	i             = keycode_i
	j             = keycode_j
	k             = keycode_k
	l             = keycode_l
	m             = keycode_m
	n             = keycode_n
	o             = keycode_o
	p             = keycode_p
	q             = keycode_q
	r             = keycode_r
	s             = keycode_s
	t             = keycode_t
	u             = keycode_u
	v             = keycode_v
	w             = keycode_w
	x             = keycode_x
	y             = keycode_y
	z             = keycode_z
	_0            = keycode_0
	_1            = keycode_1
	_2            = keycode_2
	_3            = keycode_3
	_4            = keycode_4
	_5            = keycode_5
	_6            = keycode_6
	_7            = keycode_7
	_8            = keycode_8
	_9            = keycode_9
	space         = keycode_space
	semicolon     = keycode_semicolon
	comma         = keycode_comma
	period        = keycode_period
	slash         = keycode_slash
	backtick      = keycode_backtick
	left_bracket  = keycode_left_bracket
	right_bracket = keycode_right_bracket
	backslash     = keycode_backslash
	quote         = keycode_quote
	hyphen        = keycode_hyphen
	equals        = keycode_equals
	return        = keycode_return
	enter         = keycode_return
	backspace     = keycode_backspace
	tab           = keycode_tab
	left_shift    = keycode_left_shift
	right_shift   = keycode_right_shift
	left_ctrl     = keycode_left_ctrl
	right_ctrl    = keycode_right_ctrl
	left_alt      = keycode_left_alt
	right_alt     = keycode_right_alt
	escape        = keycode_escape
	f1            = keycode_f1
	f2            = keycode_f2
	f3            = keycode_f3
	f4            = keycode_f4
	f5            = keycode_f5
	f6            = keycode_f6
	f7            = keycode_f7
	f8            = keycode_f8
	f9            = keycode_f9
	f10           = keycode_f10
	f11           = keycode_f11
	f12           = keycode_f12
	left_arrow    = keycode_left_arrow
	right_arrow   = keycode_right_arrow
	up_arrow      = keycode_up_arrow
	down_arrow    = keycode_down_arrow
	delete        = keycode_delete
}

// KeyCode.from_byte returns the KeyCode and KeyModifier for an ascii character.
@[inline]
pub fn KeyCode.from_byte(c u8) ?(KeyCode, KeyModifier) {
	return match c {
		`a` { KeyCode.a, KeyModifier.zero() }
		`A` { KeyCode.a, KeyModifier.shift }
		`b` { KeyCode.b, KeyModifier.zero() }
		`B` { KeyCode.b, KeyModifier.shift }
		`c` { KeyCode.c, KeyModifier.zero() }
		`C` { KeyCode.c, KeyModifier.shift }
		`d` { KeyCode.d, KeyModifier.zero() }
		`D` { KeyCode.d, KeyModifier.shift }
		`e` { KeyCode.e, KeyModifier.zero() }
		`E` { KeyCode.e, KeyModifier.shift }
		`f` { KeyCode.f, KeyModifier.zero() }
		`F` { KeyCode.f, KeyModifier.shift }
		`g` { KeyCode.g, KeyModifier.zero() }
		`G` { KeyCode.g, KeyModifier.shift }
		`h` { KeyCode.h, KeyModifier.zero() }
		`H` { KeyCode.h, KeyModifier.shift }
		`i` { KeyCode.i, KeyModifier.zero() }
		`I` { KeyCode.i, KeyModifier.shift }
		`j` { KeyCode.j, KeyModifier.zero() }
		`J` { KeyCode.j, KeyModifier.shift }
		`k` { KeyCode.k, KeyModifier.zero() }
		`K` { KeyCode.k, KeyModifier.shift }
		`l` { KeyCode.l, KeyModifier.zero() }
		`L` { KeyCode.l, KeyModifier.shift }
		`m` { KeyCode.m, KeyModifier.zero() }
		`M` { KeyCode.m, KeyModifier.shift }
		`n` { KeyCode.n, KeyModifier.zero() }
		`N` { KeyCode.n, KeyModifier.shift }
		`o` { KeyCode.o, KeyModifier.zero() }
		`O` { KeyCode.o, KeyModifier.shift }
		`p` { KeyCode.p, KeyModifier.zero() }
		`P` { KeyCode.p, KeyModifier.shift }
		`q` { KeyCode.q, KeyModifier.zero() }
		`Q` { KeyCode.q, KeyModifier.shift }
		`r` { KeyCode.r, KeyModifier.zero() }
		`R` { KeyCode.r, KeyModifier.shift }
		`s` { KeyCode.s, KeyModifier.zero() }
		`S` { KeyCode.s, KeyModifier.shift }
		`t` { KeyCode.t, KeyModifier.zero() }
		`T` { KeyCode.t, KeyModifier.shift }
		`u` { KeyCode.u, KeyModifier.zero() }
		`U` { KeyCode.u, KeyModifier.shift }
		`v` { KeyCode.v, KeyModifier.zero() }
		`V` { KeyCode.v, KeyModifier.shift }
		`w` { KeyCode.w, KeyModifier.zero() }
		`W` { KeyCode.w, KeyModifier.shift }
		`x` { KeyCode.x, KeyModifier.zero() }
		`X` { KeyCode.x, KeyModifier.shift }
		`y` { KeyCode.y, KeyModifier.zero() }
		`Y` { KeyCode.y, KeyModifier.shift }
		`z` { KeyCode.z, KeyModifier.zero() }
		`Z` { KeyCode.z, KeyModifier.shift }
		`0` { KeyCode._0, KeyModifier.zero() }
		`1` { KeyCode._1, KeyModifier.zero() }
		`2` { KeyCode._2, KeyModifier.zero() }
		`3` { KeyCode._3, KeyModifier.zero() }
		`4` { KeyCode._4, KeyModifier.zero() }
		`5` { KeyCode._5, KeyModifier.zero() }
		`6` { KeyCode._6, KeyModifier.zero() }
		`7` { KeyCode._7, KeyModifier.zero() }
		`8` { KeyCode._8, KeyModifier.zero() }
		`9` { KeyCode._9, KeyModifier.zero() }
		` ` { KeyCode.space, KeyModifier.zero() }
		`;` { KeyCode.semicolon, KeyModifier.zero() }
		`,` { KeyCode.comma, KeyModifier.zero() }
		`.` { KeyCode.period, KeyModifier.zero() }
		`/` { KeyCode.slash, KeyModifier.zero() }
		`\\` { KeyCode.backslash, KeyModifier.zero() }
		`'` { KeyCode.quote, KeyModifier.zero() }
		`-` { KeyCode.hyphen, KeyModifier.zero() }
		`=` { KeyCode.equals, KeyModifier.zero() }
		`\n` { KeyCode.return, KeyModifier.zero() }
		`\t` { KeyCode.tab, KeyModifier.zero() }
		`~` { KeyCode.backtick, KeyModifier.shift }
		`!` { KeyCode._1, KeyModifier.shift }
		`@` { KeyCode._2, KeyModifier.shift }
		`#` { KeyCode._3, KeyModifier.shift }
		`$` { KeyCode._4, KeyModifier.shift }
		`%` { KeyCode._5, KeyModifier.shift }
		`^` { KeyCode._6, KeyModifier.shift }
		`&` { KeyCode._7, KeyModifier.shift }
		`*` { KeyCode._8, KeyModifier.shift }
		`(` { KeyCode._9, KeyModifier.shift }
		`)` { KeyCode._0, KeyModifier.shift }
		`_` { KeyCode.hyphen, KeyModifier.shift }
		`+` { KeyCode.equals, KeyModifier.shift }
		`{` { KeyCode.left_bracket, KeyModifier.shift }
		`}` { KeyCode.right_bracket, KeyModifier.shift }
		`|` { KeyCode.backslash, KeyModifier.shift }
		`:` { KeyCode.semicolon, KeyModifier.shift }
		`"` { KeyCode.quote, KeyModifier.shift }
		`<` { KeyCode.comma, KeyModifier.shift }
		`>` { KeyCode.period, KeyModifier.shift }
		`?` { KeyCode.slash, KeyModifier.shift }
		else { return none }
	}
}

// KeyboardWriteParams is the parameters for determining how Keyboard.write behaves.
@[params]
pub struct KeyboardWriteParams {
__global:
	speed time.Duration = 50 * time.millisecond
}

// Keyboard acts as a namespace for keyboard related functions.
@[noinit]
pub struct Keyboard {}

// Keyboard.press triggers a key press.
@[inline]
pub fn Keyboard.press(key_code KeyCode, mod KeyModifier) {
	keyboard_event(key_code, mod, true)
	time.sleep(50 * time.millisecond)
	keyboard_event(key_code, mod, false)
}

// Keyboard.write types out a string.
@[inline]
pub fn Keyboard.write(str string, params KeyboardWriteParams) {
	for c in str {
		if code, mod := KeyCode.from_byte(c) {
			keyboard_event(code, mod, true)
			time.sleep(params.speed)
			keyboard_event(code, mod, false)
		}
	}
}

// keyboard_event creates an event from the given key_code and mod.
fn keyboard_event(key_code KeyCode, mod KeyModifier, is_key_down_event bool) {
	$if macos {
		mut flags := u64(0)
		if mod.has(.shift) {
			flags |= cg_event_flag_shift
		}
		if mod.has(.ctrl) {
			flags |= cg_event_flag_control
		}
		if mod.has(.alt) {
			flags |= cg_event_flag_alternate
		}
		event := C.CGEventCreateKeyboardEvent(unsafe { nil }, int(key_code), is_key_down_event)
		if event != unsafe { nil } {
			C.CGEventSetFlags(event, flags)
			C.CGEventPost(cg_hid_event_tap, event)
			C.CFRelease(event)
		}
	} $else $if windows {
		mut keys := []int{cap: 4}
		if mod.has(.shift) {
			keys << int(vk_shift)
		}
		if mod.has(.ctrl) {
			keys << int(vk_control)
		}
		if mod.has(.alt) {
			keys << int(vk_menu)
		}
		keys << int(key_code)
		if is_key_down_event {
			for key in keys {
				C.keybd_event(u8(key), 0, 0, 0)
			}
		} else {
			for key in keys.reverse() {
				C.keybd_event(u8(key), 0, keyeventf_keyup, 0)
			}
		}
	} $else $if linux {
		if Screen.compositor() == .wayland {
			wayland_key_event(key_code, mod, is_key_down_event)
		} else {
			x11_key_event(key_code, mod, is_key_down_event)
		}
	}
}

fn x11_key_event(key_code KeyCode, mod KeyModifier, is_key_down bool) {
	$if linux && $pkgconfig('x11') && $pkgconfig('xtst') {
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return
		}
		keycode := C.XKeysymToKeycode(display, u64(key_code))
		shift := C.XKeysymToKeycode(display, u64(KeyCode.left_shift))
		ctrl := C.XKeysymToKeycode(display, u64(KeyCode.left_ctrl))
		alt := C.XKeysymToKeycode(display, u64(KeyCode.left_alt))
		if is_key_down {
			if mod.has(.shift) {
				C.XTestFakeKeyEvent(display, shift, true, 0)
			}
			if mod.has(.ctrl) {
				C.XTestFakeKeyEvent(display, ctrl, true, 0)
			}
			if mod.has(.alt) {
				C.XTestFakeKeyEvent(display, alt, true, 0)
			}
			C.XTestFakeKeyEvent(display, keycode, true, 0)
		} else {
			C.XTestFakeKeyEvent(display, keycode, false, 0)
			if mod.has(.alt) {
				C.XTestFakeKeyEvent(display, alt, false, 0)
			}
			if mod.has(.ctrl) {
				C.XTestFakeKeyEvent(display, ctrl, false, 0)
			}
			if mod.has(.shift) {
				C.XTestFakeKeyEvent(display, shift, false, 0)
			}
		}
		C.XSync(display, false)
	}
}

// wayland_key_event types through the uinput virtual keyboard. Keys are
// mapped from the V enum to Linux evdev key codes.
fn wayland_key_event(key_code KeyCode, mod KeyModifier, is_key_down bool) {
	$if linux {
		if C.auto_uinput_open_keyboard() != 0 {
			return
		}
		code := keycode_to_evdev(key_code)
		if code == 0 {
			return
		}
		if is_key_down {
			if mod.has(.shift) {
				C.auto_uinput_key(42, 1)
			}
			if mod.has(.ctrl) {
				C.auto_uinput_key(29, 1)
			}
			if mod.has(.alt) {
				C.auto_uinput_key(56, 1)
			}
			C.auto_uinput_key(code, 1)
		} else {
			C.auto_uinput_key(code, 0)
			if mod.has(.alt) {
				C.auto_uinput_key(56, 0)
			}
			if mod.has(.ctrl) {
				C.auto_uinput_key(29, 0)
			}
			if mod.has(.shift) {
				C.auto_uinput_key(42, 0)
			}
		}
	}
}

// keycode_to_evdev maps a `KeyCode` to its Linux evdev (`linux/input-event-codes.h`)
// key code.
fn keycode_to_evdev(key_code KeyCode) int {
	return match key_code {
		.a { 30 }
		.b { 48 }
		.c { 46 }
		.d { 32 }
		.e { 18 }
		.f { 33 }
		.g { 34 }
		.h { 35 }
		.i { 23 }
		.j { 36 }
		.k { 37 }
		.l { 38 }
		.m { 50 }
		.n { 49 }
		.o { 24 }
		.p { 25 }
		.q { 16 }
		.r { 19 }
		.s { 31 }
		.t { 20 }
		.u { 22 }
		.v { 47 }
		.w { 17 }
		.x { 45 }
		.y { 21 }
		.z { 44 }
		._0 { 11 }
		._1 { 2 }
		._2 { 3 }
		._3 { 4 }
		._4 { 5 }
		._5 { 6 }
		._6 { 7 }
		._7 { 8 }
		._8 { 9 }
		._9 { 10 }
		.space { 57 }
		.semicolon { 39 }
		.comma { 51 }
		.period { 52 }
		.slash { 53 }
		.backtick { 41 }
		.left_bracket { 26 }
		.right_bracket { 27 }
		.backslash { 43 }
		.quote { 40 }
		.hyphen { 12 }
		.equals { 13 }
		.return { 28 }
		.backspace { 14 }
		.tab { 15 }
		.left_shift { 42 }
		.right_shift { 54 }
		.left_ctrl { 29 }
		.right_ctrl { 97 }
		.left_alt { 56 }
		.right_alt { 100 }
		.escape { 1 }
		.f1 { 59 }
		.f2 { 60 }
		.f3 { 61 }
		.f4 { 62 }
		.f5 { 63 }
		.f6 { 64 }
		.f7 { 65 }
		.f8 { 66 }
		.f9 { 67 }
		.f10 { 68 }
		.f11 { 87 }
		.f12 { 88 }
		.left_arrow { 105 }
		.right_arrow { 106 }
		.up_arrow { 103 }
		.down_arrow { 108 }
		.delete { 111 }
	}
}
