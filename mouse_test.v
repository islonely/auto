module auto

import time

fn test_interpolate_includes_endpoints() {
	assert interpolate(0, 100, 1, 1) == 100
	assert interpolate(0, 100, 2, 2) == 100
	assert interpolate(10, 20, 10, 10) == 20
}

fn test_interpolate_midpoints() {
	assert interpolate(0, 100, 1, 2) == 50
	assert interpolate(0, 100, 1, 4) == 25
	assert interpolate(0, 100, 3, 4) == 75
	assert interpolate(5, 5, 3, 7) == 5
	assert interpolate(100, 0, 1, 2) == 50
}

fn test_interpolate_single_step() {
	assert interpolate(0, 100, 0, 0) == 100
	assert interpolate(0, 100, 1, 0) == 100
}

fn test_drag_steps_is_at_least_one() {
	assert drag_steps(0) == 1
	assert drag_steps(-1 * time.second) == 1
	assert drag_steps(time.second) >= 1
}

fn test_clamp_i() {
	assert clamp_i(5, 0, 10) == 5
	assert clamp_i(-1, 0, 10) == 0
	assert clamp_i(0, 0, 10) == 0
	assert clamp_i(10, 0, 10) == 10
	assert clamp_i(11, 0, 10) == 10
}

fn test_drag_params_defaults() {
	params := DragParams{}
	assert params.button == .left
	assert params.duration == time.millisecond * 750
}

fn test_double_click_params_defaults() {
	params := DoubleClickParams{}
	assert params.button == .left
}

fn test_get_pos_opt_does_not_panic() {
	x, y := Mouse.get_pos_opt() or { return }
	_ := x
	_ := y
}
