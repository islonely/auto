import auto
import time

fn main() {
	// press a single key combined with a modifier
	auto.Keyboard.press(.a, .ctrl)

	// type a string, character by character
	auto.Keyboard.write('Hello from auto!\n', speed: 50 * time.millisecond)

	// uppercase letters and symbols are typed with the right modifiers automatically
	auto.Keyboard.write('A + 1 = 2? {yes}', speed: 30 * time.millisecond)
}
