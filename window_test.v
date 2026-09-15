module auto

import time

fn test_wait_params_defaults() {
	params := WaitParams{}
	assert params.timeout == 10 * time.second
	assert params.interval == 100 * time.millisecond
}

fn test_window_zero_handle() {
	assert !Window.exists(0)
	assert !Window.is_active(0)
	assert Window.title(0) == ''
}

fn test_wait_active_times_out_for_unknown_window() {
	result := Window.wait_active('__auto_no_such_window__',
		timeout:  200 * time.millisecond
		interval: 50 * time.millisecond
	)
	assert !result
}

fn test_wait_not_active_returns_true_for_unknown_window() {
	result := Window.wait_not_active('__auto_no_such_window__', timeout: 200 * time.millisecond)
	assert result
}

fn test_active_does_not_panic() {
	_ := Window.active()
	_ := Window.active_title()
	_ := Window.control_text(0)
}
