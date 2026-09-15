module auto

import time

// WaitParams are the options for `Window.wait_active` and
// `Window.wait_not_active`.
@[params]
pub struct WaitParams {
__global:
	timeout  time.Duration = 10 * time.second
	interval time.Duration = 100 * time.millisecond
}

// Window acts as a namespace for window related functions.
@[noinit]
pub struct Window {}

// Window.active returns the handle of the currently active (focused) window.
// Returns 0 when it cannot be determined. macOS has no portable window handle,
// so use `Window.active_title` there instead.
pub fn Window.active() int {
	$if windows {
		hwnd := C.GetForegroundWindow()
		return int(u64(hwnd))
	} $else $if linux {
		return x11_active_window()
	} $else {
		return 0
	}
}

// Window.exists reports whether `handle` refers to an existing window.
pub fn Window.exists(handle int) bool {
	$if windows {
		if handle == 0 {
			return false
		}
		return C.IsWindow(unsafe { voidptr(handle) })
	} $else $if linux {
		return x11_window_exists(handle)
	} $else {
		return false
	}
}

// Window.title returns the title of the window with the given handle. Returns
// an empty string when the title is unavailable. On macOS there is no portable
// window handle, so use `Window.active_title` instead.
pub fn Window.title(handle int) string {
	$if windows {
		return windows_window_title(handle)
	} $else $if linux {
		return x11_window_title(handle)
	} $else {
		return ''
	}
}

// Window.active_title returns the title of the currently active window.
pub fn Window.active_title() string {
	$if macos {
		return macos_active_window_title()
	}
	return Window.title(Window.active())
}

// Window.is_active reports whether `handle` is the currently active window.
pub fn Window.is_active(handle int) bool {
	if handle == 0 {
		return false
	}
	return Window.active() == handle
}

// Window.control_text returns the text of the focused control (for example the
// label of the focused button or the contents of the focused text field).
// It returns an empty string when the text cannot be read. This is not
// supported on X11/Wayland.
pub fn Window.control_text(handle int) string {
	$if windows {
		return windows_control_text(handle)
	} $else $if macos {
		return macos_focused_control_text()
	}
	return ''
}

// Window.wait_active waits until the active window's title contains `title`.
// It returns false if the timeout expires first.
pub fn Window.wait_active(title string, params WaitParams) bool {
	return wait_for_window(title, true, params)
}

// Window.wait_not_active waits until the active window's title no longer
// contains `title`. It returns false if the timeout expires first.
pub fn Window.wait_not_active(title string, params WaitParams) bool {
	return wait_for_window(title, false, params)
}

fn wait_for_window(title string, want_active bool, params WaitParams) bool {
	timeout := if params.timeout <= 0 { 10 * time.second } else { params.timeout }
	interval := if params.interval <= 0 { 100 * time.millisecond } else { params.interval }
	mut elapsed := time.Duration(0)
	for {
		is_active := Window.active_title().contains(title)
		if is_active == want_active {
			return true
		}
		if elapsed >= timeout {
			return false
		}
		time.sleep(interval)
		elapsed += interval
	}
	return false
}

// windows_window_title reads the UTF-16 window title through the Win32 API.
fn windows_window_title(handle int) string {
	$if windows {
		return windows_window_title_ptr(unsafe { voidptr(handle) })
	}
	return ''
}

fn windows_window_title_ptr(hwnd voidptr) string {
	$if windows {
		if hwnd == unsafe { nil } {
			return ''
		}
		length := C.GetWindowTextLengthW(hwnd)
		if length <= 0 {
			return ''
		}
		mut buffer := []u16{len: length + 1}
		C.GetWindowTextW(hwnd, buffer.data, length + 1)
		return unsafe { string_from_wide2(buffer.data, length) }
	}
	return ''
}

// windows_control_text returns the text of the focused control in the given
// window, falling back to the window itself.
fn windows_control_text(handle int) string {
	$if windows {
		mut hwnd := C.GetForegroundWindow()
		if handle != 0 {
			hwnd = unsafe { voidptr(handle) }
		}
		if hwnd == unsafe { nil } {
			return ''
		}
		mut process_id := u32(0)
		thread_id := C.GetWindowThreadProcessId(hwnd, &process_id)
		mut info := C.GUITHREADINFO{}
		info.cbSize = u32(sizeof(C.GUITHREADINFO))
		if C.GetGUIThreadInfo(thread_id, &info) && info.hwndFocus != unsafe { nil } {
			return windows_window_title_ptr(info.hwndFocus)
		}
		return windows_window_title_ptr(hwnd)
	}
	return ''
}

// x11_active_window returns the active window through EWMH, falling back to the
// X input focus.
fn x11_active_window() int {
	$if linux && $pkgconfig('x11') {
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return 0
		}
		root := C.XDefaultRootWindow(display)
		active_atom := C.XInternAtom(display, c'_NET_ACTIVE_WINDOW', true)
		if active_atom != 0 {
			mut actual_type := u64(0)
			mut actual_format := 0
			mut nitems := u64(0)
			mut bytes_after := u64(0)
			mut prop := &u8(unsafe { nil })
			if C.XGetWindowProperty(display, root, active_atom, 0, 1, false, 0, &actual_type,
				&actual_format, &nitems, &bytes_after, &prop) == 0 {
				if prop != unsafe { nil } {
					mut handle := u64(0)
					unsafe { vmemcpy(&handle, prop, 8) }
					C.XFree(prop)
					if handle != 0 && x11_window_exists(int(handle)) {
						return int(handle)
					}
				}
			}
		}
		mut focus := u64(0)
		mut revert := 0
		C.XGetInputFocus(display, &focus, &revert)
		// None (0) and PointerRoot (1) are not real windows.
		if focus > 1 && x11_window_exists(int(focus)) {
			return int(focus)
		}
	}
	return 0
}

// x11_window_title reads `_NET_WM_NAME` (UTF-8) and falls back to `WM_NAME`.
fn x11_window_title(handle int) string {
	$if linux && $pkgconfig('x11') {
		if handle == 0 || !x11_window_exists(handle) {
			return ''
		}
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return ''
		}
		window := u64(handle)
		name_atom := C.XInternAtom(display, c'_NET_WM_NAME', true)
		if name_atom != 0 {
			mut actual_type := u64(0)
			mut actual_format := 0
			mut nitems := u64(0)
			mut bytes_after := u64(0)
			mut prop := &u8(unsafe { nil })
			if C.XGetWindowProperty(display, window, name_atom, 0, 1024, false, 0, &actual_type,
				&actual_format, &nitems, &bytes_after, &prop) == 0 {
				if prop != unsafe { nil } && nitems > 0 {
					title := unsafe { tos(prop, int(nitems)) }
					C.XFree(prop)
					return title
				}
			}
		}
		mut name := &char(unsafe { nil })
		if C.XFetchName(display, window, &name) && name != unsafe { nil } {
			title := unsafe { cstring_to_vstring(name) }
			C.XFree(name)
			return title
		}
	}
	return ''
}

fn x11_window_exists(handle int) bool {
	$if linux && $pkgconfig('x11') {
		if handle == 0 {
			return false
		}
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return false
		}
		mut attributes := [256]u8{}
		return unsafe { C.XGetWindowAttributes(display, u64(handle), voidptr(&attributes)) }
	}
	return false
}

// macos_copy_attribute copies the named AX attribute of an element. The caller
// owns the returned value and must release it.
fn macos_copy_attribute(element voidptr, name string) voidptr {
	$if macos {
		attribute := C.CFStringCreateWithCString(unsafe { nil }, name.str, kcfstring_encoding_utf8)
		if attribute == unsafe { nil } {
			return unsafe { nil }
		}
		defer { C.CFRelease(attribute) }
		mut value := voidptr(unsafe { nil })
		if C.AXUIElementCopyAttributeValue(element, attribute, &value) != 0 {
			return unsafe { nil }
		}
		return value
	}
	return unsafe { nil }
}

// macos_copy_string returns the named AX attribute of an element as a V string.
fn macos_copy_string(element voidptr, name string) string {
	$if macos {
		value := macos_copy_attribute(element, name)
		if value == unsafe { nil } {
			return ''
		}
		defer { C.CFRelease(value) }
		if C.CFGetTypeID(value) != C.CFStringGetTypeID() {
			return ''
		}
		length := C.CFStringGetLength(value)
		if length <= 0 {
			return ''
		}
		mut buffer := []u8{len: int(length) * 4 + 1}
		if C.CFStringGetCString(value, buffer.data, i64(buffer.len), kcfstring_encoding_utf8) {
			return unsafe { cstring_to_vstring(&char(buffer.data)) }
		}
	}
	return ''
}

// macos_active_window_title uses the Accessibility API to read the title of the
// focused window. It requires the process to have Accessibility permission.
fn macos_active_window_title() string {
	$if macos {
		system := C.AXUIElementCreateSystemWide()
		if system == unsafe { nil } {
			return ''
		}
		defer { C.CFRelease(system) }
		application := macos_copy_attribute(system, 'AXFocusedApplication')
		if application == unsafe { nil } {
			return ''
		}
		defer { C.CFRelease(application) }
		window := macos_copy_attribute(application, 'AXFocusedWindow')
		if window == unsafe { nil } {
			return ''
		}
		defer { C.CFRelease(window) }
		return macos_copy_string(window, 'AXTitle')
	}
	return ''
}

// macos_focused_control_text reads the title or value of the focused UI element
// through the Accessibility API.
fn macos_focused_control_text() string {
	$if macos {
		system := C.AXUIElementCreateSystemWide()
		if system == unsafe { nil } {
			return ''
		}
		defer { C.CFRelease(system) }
		element := macos_copy_attribute(system, 'AXFocusedUIElement')
		if element == unsafe { nil } {
			return ''
		}
		defer { C.CFRelease(element) }
		title := macos_copy_string(element, 'AXTitle')
		if title != '' {
			return title
		}
		return macos_copy_string(element, 'AXValue')
	}
	return ''
}
