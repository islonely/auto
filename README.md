## Cross-Platform mouse and keyboard manipulation

Cross-platform tool to manipulate the mouse and keyboard to automate tasks.

Supports macOS, Windows, Linux (X11) and Linux (Wayland, via `uinput`).

```v
import auto
import time

fn main() {
    // get current mouse position
    x, y := auto.Mouse.get_pos()
    println('Mouse is at: X: ${x}, Y: ${y}')

    // get the dimensions of the primary display
    sz := auto.Screen.size()

    // center the mouse in the middle of the screen
    auto.Mouse.set_pos(sz.width / 2, sz.height / 2)

    // left and right click the mouse
    auto.Mouse.click(.left)
    auto.Mouse.click(.right)

    // double left click
    auto.Mouse.double_click()

    // press and hold / release a button
    auto.Mouse.button_down(.left)
    auto.Mouse.button_up(.left)

    // click and drag mouse to 100, 150
    auto.Mouse.drag_to(100, 150, button: .left, duration: time.second)

    // drag relative to the current position
    auto.Mouse.drag_rel(20, -10)

    // emulate keyboard typing
    auto.Keyboard.press(.s, .ctrl)
    auto.Keyboard.write('some message to write', speed: 100 * time.millisecond)
}
```

## Platform notes

### macOS
Synthetic events are posted through the Quartz Event Services
(`ApplicationServices`). The hosting application needs to be granted
*Accessibility* permissions for the events to reach other applications.

### Windows
The Win32 API (`SetCursorPos`, `mouse_event`, `keybd_event`) is used directly.

### Linux / X11
Build dependencies: `libx11`, `libxtst` and `libxrandr` development packages.
They are detected through `pkg-config`, so only the libraries that are present
are compiled in:

```sh
# Debian/Ubuntu
sudo apt install libx11-dev libxtst-dev libxrandr-dev
# Fedora
sudo dnf install libX11-devel libXtst-devel libXrandr-devel
# Arch
sudo pacman -S libx11 libxtst libxrandr
```

### Linux / Wayland
Wayland intentionally does not expose a protocol that lets a normal client move
the system pointer or synthesise keystrokes. This module injects input through
the kernel's `uinput` interface instead, which works on every compositor.

That requires write access to `/dev/uinput`. Either run as root or install a
udev rule and add yourself to the `input` group:

```
# /etc/udev/rules.d/99-uinput.rules
KERNEL=="uinput", GROUP="input", MODE="0660"
```

then `sudo usermod -aG input $USER` and reload the rule / reboot.

Because the pointer position cannot be read back on Wayland, `Mouse.get_pos`
returns the last position set through this module, seeded from XWayland when it
is available. When `/dev/uinput` is not accessible the Wayland backend silently
does nothing, so guard against it with `auto.Screen.compositor()` if needed.

## Testing

```sh
v test .
```

Tests that actually move the pointer and type keys are opt-in, so they do not
disturb your desktop during a normal test run:

```sh
AUTO_TEST_INPUT=1 v test .
```
