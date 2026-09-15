// Wayland input injection helper.
//
// Wayland deliberately does not expose a protocol for an ordinary client to
// move the system pointer or synthesise keystrokes. The portable, compositor
// agnostic escape hatch is the kernel's uinput interface: we create virtual
// input devices and the display server picks them up like any other keyboard
// or mouse.
//
// Using uinput requires write access to /dev/uinput. That normally means
// running as root, or installing a udev rule that grants the `input` group
// access, for example:
//
//     KERNEL=="uinput", GROUP="input", MODE="0660"
//
// This file is intentionally small and only handles the raw device plumbing;
// the public API and the coordinate logic live in the V sources.

#ifndef AUTO_UINPUT_LINUX_C
#define AUTO_UINPUT_LINUX_C

#include <linux/uinput.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/ioctl.h>

static int auto_uinput_pointer_fd = -1;
static int auto_uinput_keyboard_fd = -1;

// The virtual pointer is an absolute pointing device (a tablet), so the
// compositor applies no pointer acceleration and repeated moves always land on
// the requested pixel. Coordinates are normalised to 0..65535.
static int auto_uinput_abs_x = 65535;
static int auto_uinput_abs_y = 65535;

static void auto_uinput_emit(int fd, unsigned short type, unsigned short code, int value) {
	struct input_event ie;
	memset(&ie, 0, sizeof(ie));
	ie.type = type;
	ie.code = code;
	ie.value = value;
	if (write(fd, &ie, sizeof(ie)) < 0) {
		// Nothing sensible to do here; the device may have been torn down.
	}
}

static void auto_uinput_syn(int fd) {
	auto_uinput_emit(fd, EV_SYN, SYN_REPORT, 0);
}

// auto_uinput_open_pointer creates the virtual absolute pointer once.
// It returns 0 on success and -1 when /dev/uinput is unavailable or the device
// could not be created (e.g. missing permissions).
int auto_uinput_open_pointer(void) {
	if (auto_uinput_pointer_fd >= 0) {
		return 0;
	}
	int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
	if (fd < 0) {
		return -1;
	}
	ioctl(fd, UI_SET_EVBIT, EV_KEY);
	ioctl(fd, UI_SET_EVBIT, EV_ABS);
	ioctl(fd, UI_SET_KEYBIT, BTN_LEFT);
	ioctl(fd, UI_SET_KEYBIT, BTN_RIGHT);
	ioctl(fd, UI_SET_KEYBIT, BTN_MIDDLE);
	ioctl(fd, UI_SET_ABSBIT, ABS_X);
	ioctl(fd, UI_SET_ABSBIT, ABS_Y);

	struct uinput_abs_setup abs_x;
	memset(&abs_x, 0, sizeof(abs_x));
	abs_x.code = ABS_X;
	abs_x.absinfo.minimum = 0;
	abs_x.absinfo.maximum = auto_uinput_abs_x;
	ioctl(fd, UI_ABS_SETUP, &abs_x);

	struct uinput_abs_setup abs_y;
	memset(&abs_y, 0, sizeof(abs_y));
	abs_y.code = ABS_Y;
	abs_y.absinfo.minimum = 0;
	abs_y.absinfo.maximum = auto_uinput_abs_y;
	ioctl(fd, UI_ABS_SETUP, &abs_y);

	struct uinput_setup usetup;
	memset(&usetup, 0, sizeof(usetup));
	usetup.id.bustype = BUS_USB;
	usetup.id.vendor = 0x1234;
	usetup.id.product = 0x5678;
	usetup.id.version = 1;
	strncpy(usetup.name, "auto virtual pointer", UINPUT_MAX_NAME_SIZE - 1);
	ioctl(fd, UI_DEV_SETUP, &usetup);
	if (ioctl(fd, UI_DEV_CREATE) < 0) {
		close(fd);
		return -1;
	}
	auto_uinput_pointer_fd = fd;
	return 0;
}

// auto_uinput_pointer_move_abs moves the pointer to the given coordinates,
// expressed in the 0..65535 range of the virtual device.
int auto_uinput_pointer_move_abs(int x, int y) {
	if (auto_uinput_pointer_fd < 0) {
		return -1;
	}
	if (x < 0) {
		x = 0;
	}
	if (x > auto_uinput_abs_x) {
		x = auto_uinput_abs_x;
	}
	if (y < 0) {
		y = 0;
	}
	if (y > auto_uinput_abs_y) {
		y = auto_uinput_abs_y;
	}
	auto_uinput_emit(auto_uinput_pointer_fd, EV_ABS, ABS_X, x);
	auto_uinput_emit(auto_uinput_pointer_fd, EV_ABS, ABS_Y, y);
	auto_uinput_syn(auto_uinput_pointer_fd);
	return 0;
}

// auto_uinput_pointer_button presses (down != 0) or releases a mouse button.
// 0 is left, 1 is right and 2 is middle.
int auto_uinput_pointer_button(int button, int down) {
	if (auto_uinput_pointer_fd < 0) {
		return -1;
	}
	int code = BTN_LEFT;
	if (button == 1) {
		code = BTN_RIGHT;
	} else if (button == 2) {
		code = BTN_MIDDLE;
	}
	auto_uinput_emit(auto_uinput_pointer_fd, EV_KEY, code, down ? 1 : 0);
	auto_uinput_syn(auto_uinput_pointer_fd);
	return 0;
}

// auto_uinput_open_keyboard creates the virtual keyboard once.
int auto_uinput_open_keyboard(void) {
	if (auto_uinput_keyboard_fd >= 0) {
		return 0;
	}
	int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
	if (fd < 0) {
		return -1;
	}
	ioctl(fd, UI_SET_EVBIT, EV_KEY);
	for (int i = 0; i < KEY_MAX; i++) {
		ioctl(fd, UI_SET_KEYBIT, i);
	}
	struct uinput_setup usetup;
	memset(&usetup, 0, sizeof(usetup));
	usetup.id.bustype = BUS_USB;
	usetup.id.vendor = 0x1234;
	usetup.id.product = 0x5679;
	usetup.id.version = 1;
	strncpy(usetup.name, "auto virtual keyboard", UINPUT_MAX_NAME_SIZE - 1);
	ioctl(fd, UI_DEV_SETUP, &usetup);
	if (ioctl(fd, UI_DEV_CREATE) < 0) {
		close(fd);
		return -1;
	}
	auto_uinput_keyboard_fd = fd;
	return 0;
}

// auto_uinput_key presses (down != 0) or releases an evdev key code.
int auto_uinput_key(int code, int down) {
	if (auto_uinput_keyboard_fd < 0) {
		return -1;
	}
	auto_uinput_emit(auto_uinput_keyboard_fd, EV_KEY, (unsigned short) code, down ? 1 : 0);
	auto_uinput_syn(auto_uinput_keyboard_fd);
	return 0;
}

#endif // AUTO_UINPUT_LINUX_C
