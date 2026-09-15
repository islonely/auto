import auto
import time

fn main() {
	compositor := auto.Screen.compositor()
	println('compositor: ${compositor}')

	if compositor == .wayland {
		println('On Wayland, input is injected through the kernel uinput interface.')
		println('Make sure /dev/uinput is accessible (see the README).')
	}

	// this works on X11, Wayland and XWayland alike
	size := auto.Screen.size()
	auto.Mouse.set_pos(size.width / 2, size.height / 2)
	auto.Mouse.click(.left)
	auto.Keyboard.write('hello from wayland', speed: 30 * time.millisecond)
}
