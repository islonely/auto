import auto
import time

fn main() {
	// print the current cursor position
	x, y := auto.Mouse.get_pos()
	println('mouse is at ${x}, ${y}')

	// move the mouse to the top left, then to the middle of the primary display
	size := auto.Screen.size()
	auto.Mouse.set_pos(0, 0)
	time.sleep(200 * time.millisecond)
	auto.Mouse.set_pos(size.width / 2, size.height / 2)

	// left click, then double click with the right button
	auto.Mouse.click(.left)
	auto.Mouse.double_click(button: .right)

	// press and hold the left button while dragging to 100, 150
	auto.Mouse.drag_to(100, 150, button: .left, duration: 500 * time.millisecond)

	// drag relative to the current position
	auto.Mouse.drag_rel(20, -20, duration: 200 * time.millisecond)
}
