module auto

import os
import time

// Input injection tests move the real cursor and type real keys, so they are
// opt-in. Run them with `AUTO_TEST_INPUT=1 v test .`.
fn input_tests_enabled() bool {
	return os.getenv('AUTO_TEST_INPUT') == '1'
}

fn test_mouse_set_get_pos_roundtrip() {
	if !input_tests_enabled() {
		return
	}
	Mouse.set_pos(25, 35)
	x, y := Mouse.get_pos()
	assert x == 25
	assert y == 35
}

fn test_mouse_click_does_not_panic() {
	if !input_tests_enabled() {
		return
	}
	Mouse.click(.left)
	Mouse.double_click()
	Mouse.button_down(.right)
	Mouse.button_up(.right)
}

fn test_mouse_drag_does_not_panic() {
	if !input_tests_enabled() {
		return
	}
	Mouse.drag_to(40, 50, duration: 30 * time.millisecond)
	Mouse.drag_rel(5, 5, duration: 20 * time.millisecond)
}

fn test_keyboard_does_not_panic() {
	if !input_tests_enabled() {
		return
	}
	Keyboard.press(.a, .shift)
	Keyboard.write('ok', speed: time.millisecond)
}
