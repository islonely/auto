module auto

fn test_compositor_is_known() {
	compositor := Screen.compositor()
	assert compositor in [Compositor.quartz, Compositor.windows, Compositor.x11, Compositor.wayland,
		Compositor.unknown]
}

fn test_size_is_non_negative() {
	size := Screen.size()
	assert size.width >= 0
	assert size.height >= 0
}

fn test_refresh_rate_is_optional() {
	_ := Screen.refresh_rate() or { -1 }
}
