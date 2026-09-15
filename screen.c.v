module auto

import os

// Compositor is the window compositor being used by the system.
pub enum Compositor {
	unknown
	wayland
	x11
	quartz
	windows
}

// Screen acts as a namespace for screen related functions.
@[noinit]
pub struct Screen {}

// Screen.compositor gets whether or not a user has X11 or Wayland as
// their window compositor.
pub fn Screen.compositor() Compositor {
	$if macos {
		return .quartz
	} $else $if windows {
		return .windows
	} $else $if linux {
		session := os.getenv_opt('XDG_SESSION_TYPE') or { '' }
		if session == 'wayland' {
			return .wayland
		}
		if os.getenv_opt('WAYLAND_DISPLAY') or { '' } != '' {
			return .wayland
		}
		return .x11
	} $else {
		return .unknown
	}
	return .unknown
}

// Screen.size returns the size of the primary display.
pub fn Screen.size() Size {
	$if macos {
		bounds := C.CGDisplayBounds(C.CGMainDisplayID())
		return Size{
			width:  int(bounds.size.width)
			height: int(bounds.size.height)
		}
	} $else $if windows {
		return Size{
			width:  C.GetSystemMetrics(sm_cxscreen)
			height: C.GetSystemMetrics(sm_cyscreen)
		}
	} $else $if linux {
		if size := x11_screen_size() {
			return size
		}
		return Size{}
	} $else {
		return Size{}
	}
}

// Screen.refresh_rate returns the screen refresh rate of the primary display.
pub fn Screen.refresh_rate() ?int {
	$if macos {
		display := C.CGMainDisplayID()
		mode := C.CGDisplayCopyDisplayMode(display)
		if mode == unsafe { nil } {
			return none
		}
		defer { C.CGDisplayModeRelease(mode) }
		rate := C.CGDisplayModeGetRefreshRate(mode)
		if rate <= 0 {
			return none
		}
		return int(rate)
	} $else $if windows {
		mut devmode := C.DEVMODE{}
		devmode.dmSize = u16(sizeof(C.DEVMODE))
		if C.EnumDisplaySettings(unsafe { nil }, enum_current_settings, &devmode) {
			if devmode.dmDisplayFrequency > 0 {
				return int(devmode.dmDisplayFrequency)
			}
		}
		return none
	} $else $if linux {
		return x11_refresh_rate()
	} $else {
		return none
	}
	return none
}

// x11_display returns a lazily created, persistent connection to the X server.
// Reusing one connection is both faster and required for the pointer position
// to stick: some servers (notably Xvfb) reset the pointer when the client that
// moved it disconnects.
@[unsafe]
fn x11_display() voidptr {
	mut static handle := u64(0)
	$if linux && $pkgconfig('x11') {
		if handle == 0 {
			handle = u64(C.XOpenDisplay(unsafe { nil }))
		}
	}
	return unsafe { voidptr(handle) }
}

// x11_screen_size returns the size of the primary display. It uses XRandR when
// available and falls back to the whole X screen.
fn x11_screen_size() ?Size {
	$if linux && $pkgconfig('x11') {
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return none
		}
		$if $pkgconfig('xrandr') {
			if info := x11_primary_info(display) {
				return Size{
					width:  int(info.width)
					height: int(info.height)
				}
			}
		}
		screen := C.XDefaultScreen(display)
		return Size{
			width:  C.XDisplayWidth(display, screen)
			height: C.XDisplayHeight(display, screen)
		}
	}
	return none
}

// x11_primary_origin returns the top left corner of the primary display. Mouse
// coordinates are reported relative to it, which keeps them consistent with
// `Screen.size`.
fn x11_primary_origin() (int, int) {
	$if linux && $pkgconfig('x11') {
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return 0, 0
		}
		$if $pkgconfig('xrandr') {
			if info := x11_primary_info(display) {
				return int(info.x), int(info.y)
			}
		}
	}
	return 0, 0
}

$if linux && $pkgconfig('xrandr') {
	fn x11_primary_info(display voidptr) ?C.XRRCrtcInfo {
		root := C.XDefaultRootWindow(display)
		resources := C.XRRGetScreenResources(display, root)
		if resources == unsafe { nil } {
			return none
		}
		defer { C.XRRFreeScreenResources(resources) }
		primary_output := C.XRRGetOutputPrimary(display, root)
		if primary_output == 0 {
			return none
		}
		for i := 0; i < resources.noutput; i++ {
			output := unsafe { resources.outputs[i] }
			if output == primary_output {
				output_info := C.XRRGetOutputInfo(display, resources, output)
				if output_info == unsafe { nil } {
					return none
				}
				defer { C.XRRFreeOutputInfo(output_info) }
				crtc_info := C.XRRGetCrtcInfo(display, resources, output_info.crtc)
				if crtc_info == unsafe { nil } {
					return none
				}
				val := *crtc_info
				defer { C.XRRFreeCrtcInfo(crtc_info) }
				return val
			}
		}
		return none
	}
}

fn x11_refresh_rate() ?int {
	$if linux && $pkgconfig('x11') && $pkgconfig('xrandr') {
		display := unsafe { x11_display() }
		if display == unsafe { nil } {
			return none
		}
		info := x11_primary_info(display) or { return none }
		root := C.XDefaultRootWindow(display)
		resources := C.XRRGetScreenResources(display, root)
		if resources == unsafe { nil } {
			return none
		}
		defer { C.XRRFreeScreenResources(resources) }
		for i := 0; i < resources.nmode; i++ {
			mode := unsafe { resources.modes[i] }
			if mode.id == info.mode {
				total := f64(mode.hTotal) * f64(mode.vTotal)
				if total <= 0 {
					return none
				}
				return int(f64(mode.dotClock) / total)
			}
		}
		return none
	}
	return none
}
