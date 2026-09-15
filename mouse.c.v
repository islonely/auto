module auto

import time

// Button is the buttons on a mouse or touchpad.
pub enum Button {
	left
	right
	middle
}

// EventType is the macOS `CGEventType` used when posting synthetic events.
// Only used on macOS.
enum EventType {
	tap_disabled_by_timeout    = -2
	tap_disabled_by_user_input = -1
	cg_null                    = 0
	left_mouse_down            = 1
	left_mouse_up              = 2
	right_mouse_down           = 3
	right_mouse_up             = 4
	mouse_moved                = 5
	left_mouse_dragged         = 6
	right_mouse_dragged        = 7
	key_down                   = 10
	key_up                     = 11
	flags_changed              = 12
	scroll_wheel               = 22
	tablet_pointer             = 23
	tablet_proximity           = 24
	other_mouse_down           = 25
	other_mouse_up             = 26
	other_mouse_dragged        = 27
}

// Mouse acts as a namespace for mouse related functions.
@[noinit]
pub struct Mouse {}

// Mouse.get_pos returns the global X and Y coordinates of the mouse cursor.
// Returns -1, -1 if there is an error getting the mouse position.
//
// On Wayland the pointer position cannot be queried directly, so a best effort
// is made: the last position set through this module is returned, seeded from
// XWayland when it is available.
pub fn Mouse.get_pos() (int, int) {
	$if macos {
		event := C.CGEventCreate(unsafe { nil })
		if event == unsafe { nil } {
			return -1, -1
		}
		point := C.CGEventGetLocation(event)
		C.CFRelease(event)
		return int(point.x), int(point.y)
	} $else $if windows {
		mut point := C.POINT{}
		if C.GetCursorPos(&point) {
			return point.x, point.y
		}
		return -1, -1
	} $else $if linux {
		if Screen.compositor() == .wayland {
			return wayland_get_pos()
		}
		return x11_get_pos()
	} $else {
		return -1, -1
	}
}

// Mouse.get_pos_opt returns the global X and Y coordinates of the mouse cursor.
@[inline]
pub fn Mouse.get_pos_opt() ?(int, int) {
	x, y := Mouse.get_pos()
	if -1 in [x, y] {
		return none
	}
	return x, y
}

// Mouse.set_pos immediately moves the mouse cursor to the `x`, `y`.
pub fn Mouse.set_pos(x int, y int) {
	$if macos {
		C.CGWarpMouseCursorPosition(C.CGPoint{
			x: f64(x)
			y: f64(y)
		})
	} $else $if windows {
		C.SetCursorPos(x, y)
	} $else $if linux {
		if Screen.compositor() == .wayland {
			wayland_set_pos(x, y)
		} else {
			x11_set_pos(x, y)
		}
	}
}

// Mouse.click triggers a mouse click event at the current mouse cursor position.
pub fn Mouse.click(button Button) {
	mouse_button_event(button, true)
	mouse_button_event(button, false)
}

// DoubleClickParams are the options for `Mouse.double_click`.
@[params]
pub struct DoubleClickParams {
pub mut:
	button Button = .left
}

// Mouse.double_click triggers a double click event at the current mouse cursor position.
@[inline]
pub fn Mouse.double_click(params DoubleClickParams) {
	Mouse.click(params.button)
	Mouse.click(params.button)
}

// Mouse.button_down presses and holds a mouse button at the current position.
@[inline]
pub fn Mouse.button_down(button Button) {
	mouse_button_event(button, true)
}

// Mouse.button_up releases a held mouse button at the current position.
@[inline]
pub fn Mouse.button_up(button Button) {
	mouse_button_event(button, false)
}

// DragParams are the options for determining how the mouse is dragged
// across the screen.
@[params]
pub struct DragParams {
__global:
	duration time.Duration = time.millisecond * 750
	button   Button        = .left
}

// Mouse.drag_rel drags the mouse cursor relative to the current location of
// the mouse.
@[inline]
pub fn Mouse.drag_rel(rel_x int, rel_y int, params DragParams) {
	cur_x, cur_y := Mouse.get_pos()
	Mouse.drag_to(cur_x + rel_x, cur_y + rel_y, params)
}

// Mouse.drag_to moves the mouse cursor while holding down a mouse button.
pub fn Mouse.drag_to(target_x int, target_y int, params DragParams) {
	$if macos {
		macos_drag(target_x, target_y, params)
	} $else {
		generic_drag(target_x, target_y, params)
	}
}

// interpolate returns the point `step` of `steps` along the line from `start`
// to `end`, including both end points.
fn interpolate(start int, end int, step int, steps int) int {
	if steps <= 1 {
		return end
	}
	return start + int(f64(end - start) * f64(step) / f64(steps))
}

// drag_steps decides how many intermediate positions a drag should use, based
// on the duration and the display refresh rate.
fn drag_steps(duration time.Duration) int {
	if duration <= 0 {
		return 1
	}
	mut rate := Screen.refresh_rate() or { 60 }
	if rate <= 0 {
		rate = 60
	}
	steps := int(f64(rate) * f64(duration) / f64(time.second))
	return if steps < 1 { 1 } else { steps }
}

fn clamp_i(value int, min int, max int) int {
	if value < min {
		return min
	}
	if value > max {
		return max
	}
	return value
}

// generic_drag holds a button down and steps the cursor towards the target
// using the platform's `Mouse.set_pos`. It is used on Windows and Linux.
fn generic_drag(target_x int, target_y int, params DragParams) {
	start_x, start_y := Mouse.get_pos()
	mut from_x := start_x
	mut from_y := start_y
	if from_x < 0 || from_y < 0 {
		from_x = target_x
		from_y = target_y
	}
	duration := if params.duration <= 0 { time.second } else { params.duration }
	steps := drag_steps(duration)
	sleep_for := duration / time.Duration(steps)
	mouse_button_event(params.button, true)
	for i := 1; i <= steps; i++ {
		Mouse.set_pos(interpolate(from_x, target_x, i, steps), interpolate(from_y, target_y, i,
			steps))
		time.sleep(sleep_for)
	}
	Mouse.set_pos(target_x, target_y)
	mouse_button_event(params.button, false)
}

fn mouse_button_event(button Button, is_down bool) {
	$if macos {
		x, y := Mouse.get_pos()
		events := macos_button_events(button)
		event_type := if is_down { events.down } else { events.up }
		point := C.CGPoint{
			x: f64(x)
			y: f64(y)
		}
		event := C.CGEventCreateMouseEvent(unsafe { nil }, event_type, point, events.button)
		if event != unsafe { nil } {
			C.CGEventPost(cg_hid_event_tap, event)
			C.CFRelease(event)
		}
	} $else $if windows {
		flag := match button {
			.left {
				if is_down { mouseeventf_leftdown } else { mouseeventf_leftup }
			}
			.right {
				if is_down { mouseeventf_rightdown } else { mouseeventf_rightup }
			}
			.middle {
				if is_down { mouseeventf_middledown } else { mouseeventf_middleup }
			}
		}

		C.mouse_event(flag, 0, 0, 0, 0)
	} $else $if linux {
		if Screen.compositor() == .wayland {
			wayland_button(button, is_down)
		} else {
			x11_button(button, is_down)
		}
	}
}

// MacosButtonEvents holds the macOS event types and button id for a mouse
// button.
struct MacosButtonEvents {
	down   int
	up     int
	button int
}

fn macos_button_events(button Button) MacosButtonEvents {
	$if macos {
		return match button {
			.left {
				MacosButtonEvents{
					down:   int(EventType.left_mouse_down)
					up:     int(EventType.left_mouse_up)
					button: cg_mouse_button_left
				}
			}
			.right {
				MacosButtonEvents{
					down:   int(EventType.right_mouse_down)
					up:     int(EventType.right_mouse_up)
					button: cg_mouse_button_right
				}
			}
			.middle {
				MacosButtonEvents{
					down:   int(EventType.other_mouse_down)
					up:     int(EventType.other_mouse_up)
					button: cg_mouse_button_center
				}
			}
		}
	} $else {
		return MacosButtonEvents{}
	}
}

fn macos_drag(target_x int, target_y int, params DragParams) {
	$if macos {
		start_x, start_y := Mouse.get_pos()
		duration := if params.duration <= 0 { time.second } else { params.duration }
		steps := drag_steps(duration)
		sleep_for := duration / time.Duration(steps)
		events := macos_button_events(params.button)
		drag_type := match params.button {
			.left { int(EventType.left_mouse_dragged) }
			.right { int(EventType.right_mouse_dragged) }
			.middle { int(EventType.other_mouse_dragged) }
		}

		start_point := C.CGPoint{
			x: f64(start_x)
			y: f64(start_y)
		}
		target_point := C.CGPoint{
			x: f64(target_x)
			y: f64(target_y)
		}
		down_event := C.CGEventCreateMouseEvent(unsafe { nil }, events.down, start_point,
			events.button)
		if down_event != unsafe { nil } {
			C.CGEventPost(cg_hid_event_tap, down_event)
			C.CFRelease(down_event)
		}
		for i := 1; i <= steps; i++ {
			current_point := C.CGPoint{
				x: f64(interpolate(start_x, target_x, i, steps))
				y: f64(interpolate(start_y, target_y, i, steps))
			}
			drag_event := C.CGEventCreateMouseEvent(unsafe { nil }, drag_type, current_point,
				events.button)
			if drag_event != unsafe { nil } {
				C.CGEventPost(cg_hid_event_tap, drag_event)
				C.CFRelease(drag_event)
			}
			time.sleep(sleep_for)
		}
		up_event := C.CGEventCreateMouseEvent(unsafe { nil }, events.up, target_point,
			events.button)
		if up_event != unsafe { nil } {
			C.CGEventPost(cg_hid_event_tap, up_event)
			C.CFRelease(up_event)
		}
	}
}

fn x11_get_pos() (int, int) {
	$if linux && $pkgconfig('x11') {
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return -1, -1
		}
		root := C.XDefaultRootWindow(display)
		mut root_id := u64(0)
		mut child_id := u64(0)
		mut pos_x := 0
		mut pos_y := 0
		mut win_x := 0
		mut win_y := 0
		mut mask := u32(0)
		C.XQueryPointer(display, root, &root_id, &child_id, &pos_x, &pos_y, &win_x, &win_y, &mask)
		origin_x, origin_y := x11_primary_origin()
		return pos_x - origin_x, pos_y - origin_y
	} $else {
		return -1, -1
	}
}

fn x11_set_pos(x int, y int) {
	$if linux && $pkgconfig('x11') {
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return
		}
		root := C.XDefaultRootWindow(display)
		origin_x, origin_y := x11_primary_origin()
		C.XWarpPointer(display, 0, root, 0, 0, 0, 0, origin_x + x, origin_y + y)
		C.XSync(display, false)
	}
}

fn x11_button(button Button, is_down bool) {
	$if linux && $pkgconfig('x11') && $pkgconfig('xtst') {
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return
		}
		num := match button {
			.left { u32(1) }
			.right { u32(3) }
			.middle { u32(2) }
		}

		C.XTestFakeButtonEvent(display, num, is_down, 0)
		C.XSync(display, false)
	}
}

// WaylandCursor is the best effort cursor position tracked on Wayland, where
// the real pointer position cannot be queried.
struct WaylandCursor {
	x int
	y int
}

@[unsafe]
fn wayland_cursor(x int, y int, set bool) WaylandCursor {
	mut static cur_x := -1
	mut static cur_y := -1
	if set {
		cur_x = x
		cur_y = y
	}
	return WaylandCursor{
		x: cur_x
		y: cur_y
	}
}

// Wayland pointer support goes through uinput. The virtual pointer is an
// absolute device, so no cursor acceleration is applied and the coordinates
// map directly onto the screen. The last position is tracked because the
// compositor does not let us query the real cursor position.
fn wayland_get_pos() (int, int) {
	cur := unsafe { wayland_cursor(0, 0, false) }
	if cur.x >= 0 {
		return cur.x, cur.y
	}
	mut pos_x := -1
	mut pos_y := -1
	$if linux && $pkgconfig('x11') {
		cur_x, cur_y := x11_get_pos()
		if cur_x >= 0 {
			unsafe { wayland_cursor(cur_x, cur_y, true) }
			pos_x = cur_x
			pos_y = cur_y
		}
	}
	return pos_x, pos_y
}

fn wayland_set_pos(x int, y int) {
	$if linux {
		if C.auto_uinput_open_pointer() != 0 {
			return
		}
		sz := Screen.size()
		width := if sz.width > 1 { sz.width - 1 } else { 1919 }
		height := if sz.height > 1 { sz.height - 1 } else { 1079 }
		abs_x := x * uinput_abs_max / width
		abs_y := y * uinput_abs_max / height
		C.auto_uinput_pointer_move_abs(clamp_i(abs_x, 0, uinput_abs_max), clamp_i(abs_y, 0,
			uinput_abs_max))
		unsafe { wayland_cursor(x, y, true) }
	}
}

fn wayland_button(button Button, is_down bool) {
	$if linux {
		if C.auto_uinput_open_pointer() != 0 {
			return
		}
		num := match button {
			.left { 0 }
			.right { 1 }
			.middle { 2 }
		}

		C.auto_uinput_pointer_button(num, if is_down { 1 } else { 0 })
	}
}
