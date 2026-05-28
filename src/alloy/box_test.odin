package alloy

import "core:testing"
import "core:strings"

@(test)
test_box_init_defaults :: proc(t: ^testing.T) {
	box: Box
	box_init(&box, 20)
	testing.expect_value(t, box.width, 20)
	testing.expect_value(t, box.border, BoxStyle.Rounded)
	testing.expect(t, !box.focused, "box should not be focused by default")
}

@(test)
test_box_render_returns_content :: proc(t: ^testing.T) {
	box: Box
	box_init(&box, 20)
	lines := []string{"hello"}
	result := box_render(box, lines)
	testing.expect(t, strings.contains(result, "hello"), "render should contain content")
}

@(test)
test_box_render_contains_title :: proc(t: ^testing.T) {
	box: Box
	box_init(&box, 20)
	box.title = "My Title"
	lines := []string{"content"}
	result := box_render(box, lines)
	testing.expect(t, strings.contains(result, "My Title"), "render should contain title")
}

@(test)
test_box_render_no_title_no_divider :: proc(t: ^testing.T) {
	box: Box
	box_init(&box, 20)
	lines := []string{"content"}
	result := box_render(box, lines)
	// Without title, mid_left char (├) should not appear
	testing.expect(t, !strings.contains(result, "├"), "no title means no divider row")
}

@(test)
test_box_render_all_styles_compile :: proc(t: ^testing.T) {
	lines := []string{"test"}
	for border_style in BoxStyle {
		box: Box
		box_init(&box, 10)
		box.border = border_style
		result := box_render(box, lines)
		testing.expect(t, len(result) > 0, "each style should render non-empty output")
	}
}
