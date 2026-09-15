import auto
import time

fn main() {
	println('active window: ${auto.Window.active_title()}')

	handle := auto.Window.active()
	if handle != 0 {
		println('handle ${handle}: ${auto.Window.title(handle)}')
		println('focused control: ${auto.Window.control_text(handle)}')
	}

	// wait up to 5 seconds for a window whose title contains "Editor"
	if auto.Window.wait_active('Editor', timeout: 5 * time.second) {
		println('an Editor window is now active')
	} else {
		println('no Editor window became active')
	}

	// wait until no window titled "Editor" is active any more
	if auto.Window.wait_not_active('Editor', timeout: 5 * time.second) {
		println('the Editor window is no longer active')
	} else {
		println('the Editor window is still active')
	}
}
