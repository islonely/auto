module auto

$if linux {
	$if $pkgconfig('x11') {
		#pkgconfig x11
		#include <X11/Xlib.h>
		#include <X11/Xutil.h>

		fn C.XOpenDisplay(&char) voidptr
		fn C.XCloseDisplay(voidptr) int
		fn C.XDefaultRootWindow(voidptr) u64
		fn C.XDefaultScreen(voidptr) int
		fn C.XDisplayWidth(voidptr, int) int
		fn C.XDisplayHeight(voidptr, int) int
		fn C.XQueryPointer(voidptr, u64, &u64, &u64, &int, &int, &int, &int, &u32) bool
		fn C.XWarpPointer(voidptr, u64, u64, int, int, int, int, int, int) int
		fn C.XFlush(voidptr) int
		fn C.XSync(voidptr, bool) int
		fn C.XKeysymToKeycode(voidptr, u64) u8
		fn C.XInternAtom(voidptr, &char, bool) u64
		fn C.XGetWindowProperty(voidptr, u64, u64, i64, i64, bool, u64, &u64, &int, &u64, &u64, &&u8) int
		fn C.XFree(voidptr) int
		fn C.XGetInputFocus(voidptr, &u64, &int) int
		fn C.XFetchName(voidptr, u64, &&char) bool
		fn C.XGetWindowAttributes(voidptr, u64, voidptr) bool
	}

	$if $pkgconfig('xtst') {
		#pkgconfig xtst
		#include <X11/extensions/XTest.h>

		fn C.XTestFakeButtonEvent(voidptr, u32, bool, u64) int
		fn C.XTestFakeKeyEvent(voidptr, u32, bool, u64) int
		fn C.XTestFakeMotionEvent(voidptr, int, int, int, u64) int
	}

	$if $pkgconfig('xrandr') {
		#pkgconfig xrandr
		#include <X11/extensions/Xrandr.h>

		@[typedef]
		struct C.XRRScreenResources {
			ncrtc   int
			crtcs   &u64
			noutput int
			outputs &u64
			nmode   int
			modes   &C.XRRModeInfo
		}

		@[typedef]
		struct C.XRRModeInfo {
			id       u64
			width    u32
			height   u32
			dotClock u64
			hTotal   u32
			vTotal   u32
		}

		@[typedef]
		struct C.XRROutputInfo {
			crtc u64
		}

		@[typedef]
		struct C.XRRCrtcInfo {
			x      int
			y      int
			width  u32
			height u32
			mode   u64
		}

		fn C.XRRGetScreenResources(voidptr, u64) &C.XRRScreenResources
		fn C.XRRGetOutputPrimary(voidptr, u64) u64
		fn C.XRRFreeScreenResources(&C.XRRScreenResources)
		fn C.XRRGetOutputInfo(voidptr, &C.XRRScreenResources, u64) &C.XRROutputInfo
		fn C.XRRFreeOutputInfo(&C.XRROutputInfo)
		fn C.XRRGetCrtcInfo(voidptr, &C.XRRScreenResources, u64) &C.XRRCrtcInfo
		fn C.XRRFreeCrtcInfo(&C.XRRCrtcInfo)
	}

	// Wayland input injection goes through the kernel's uinput interface, which
	// is compositor agnostic. The heavy lifting lives in a small C helper so that
	// the ioctl() request numbers and struct layouts come from the kernel headers
	// instead of being hardcoded.
	#include "@DIR/c/uinput_linux.c"

	fn C.auto_uinput_open_pointer() int
	fn C.auto_uinput_pointer_move_abs(int, int) int
	fn C.auto_uinput_pointer_button(int, int) int
	fn C.auto_uinput_open_keyboard() int
	fn C.auto_uinput_key(int, int) int

	const uinput_abs_max = 65535
} $else $if windows {
	#include <windows.h>

	const enum_current_settings = u32(0xFFFFFFFF)
	const sm_cxscreen = 0
	const sm_cyscreen = 1
	const mouseeventf_move = u32(0x0001)
	const mouseeventf_leftdown = u32(0x0002)
	const mouseeventf_leftup = u32(0x0004)
	const mouseeventf_rightdown = u32(0x0008)
	const mouseeventf_rightup = u32(0x0010)
	const mouseeventf_middledown = u32(0x0020)
	const mouseeventf_middleup = u32(0x0040)
	const keyeventf_keyup = u32(0x0002)
	const vk_shift = u8(0x10)
	const vk_control = u8(0x11)
	const vk_menu = u8(0x12)

	@[typedef]
	struct C.POINT {
		x int
		y int
	}

	@[typedef]
	struct C.DEVMODE {
		dmDisplayFrequency u32
		dmSize             u16
	}

	fn C.GetCursorPos(&C.POINT) bool
	fn C.SetCursorPos(int, int) bool
	fn C.GetSystemMetrics(int) int
	fn C.mouse_event(u32, u32, u32, u32, u64)
	fn C.EnumDisplaySettings(&char, u32, &C.DEVMODE) bool
	fn C.keybd_event(u8, u8, u32, u64)

	@[typedef]
	struct C.RECT {
		left   int
		top    int
		right  int
		bottom int
	}

	@[typedef]
	struct C.GUITHREADINFO {
		cbSize        u32
		flags         u32
		hwndActive    voidptr
		hwndFocus     voidptr
		hwndCapture   voidptr
		hwndMenuOwner voidptr
		hwndMoveSize  voidptr
		hwndCaret     voidptr
		rcCaret       C.RECT
	}

	fn C.GetForegroundWindow() voidptr
	fn C.IsWindow(voidptr) bool
	fn C.GetWindowTextLengthW(voidptr) int
	fn C.GetWindowTextW(voidptr, &u16, int) int
	fn C.GetWindowThreadProcessId(voidptr, &u32) u32
	fn C.GetGUIThreadInfo(u32, voidptr) bool
} $else $if macos {
	#flag -framework ApplicationServices
	#include <ApplicationServices/ApplicationServices.h>

	const cg_hid_event_tap = 0
	const cg_mouse_button_left = 0
	const cg_mouse_button_right = 1
	const cg_mouse_button_center = 2
	const cg_event_flag_shift = u64(0x00020000)
	const cg_event_flag_control = u64(0x00040000)
	const cg_event_flag_alternate = u64(0x00080000)

	@[typedef]
	struct C.CGPoint {
	__global:
		x f64
		y f64
	}

	@[typedef]
	struct C.CGSize {
	__global:
		width  f64
		height f64
	}

	@[typedef]
	struct C.CGRect {
	__global:
		origin C.CGPoint
		size   C.CGSize
	}

	fn C.CGDisplayBounds(u32) C.CGRect
	fn C.CGMainDisplayID() u32
	fn C.CGWarpMouseCursorPosition(C.CGPoint) int
	fn C.CGEventCreate(voidptr) voidptr
	fn C.CGEventGetLocation(voidptr) C.CGPoint
	fn C.CGEventCreateMouseEvent(voidptr, int, C.CGPoint, int) voidptr
	fn C.CGEventCreateKeyboardEvent(voidptr, int, bool) voidptr
	fn C.CGEventSetFlags(voidptr, u64)
	fn C.CFRelease(voidptr)
	fn C.CGEventPost(int, voidptr)
	fn C.CGDisplayCopyDisplayMode(u32) voidptr
	fn C.CGDisplayModeGetRefreshRate(voidptr) f64
	fn C.CGDisplayModeRelease(voidptr)

	const kcfstring_encoding_utf8 = u32(0x08000100)

	fn C.AXUIElementCreateSystemWide() voidptr
	fn C.AXUIElementCopyAttributeValue(voidptr, voidptr, &voidptr) int
	fn C.CFStringCreateWithCString(voidptr, &u8, u32) voidptr
	fn C.CFStringGetCString(voidptr, &u8, i64, u32) bool
	fn C.CFStringGetLength(voidptr) i64
	fn C.CFStringGetTypeID() u64
	fn C.CFGetTypeID(voidptr) u64
} $else {
	$compile_error('auto: unsupported operating system')
}

// Size is the width and height of a screen.
pub struct Size {
__global:
	width  int
	height int
}

// Pos is the X and Y coordinates on a screen.
pub struct Pos {
__global:
	x int
	y int
}
