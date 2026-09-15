import auto

fn main() {
	println('compositor: ${auto.Screen.compositor()}')

	size := auto.Screen.size()
	println('primary display: ${size.width}x${size.height}')

	if rate := auto.Screen.refresh_rate() {
		println('refresh rate: ${rate} Hz')
	} else {
		println('refresh rate: unknown')
	}
}
