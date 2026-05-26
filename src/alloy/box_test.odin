package alloy

import "core:testing"
import "core:strings"

@(test)
test_visible_len_plain_string :: proc(t: ^testing.T) {
	testing.expect_value(t, visible_len("hello"), 5)
}

@(test)
test_visible_len_empty_string :: proc(t: ^testing.T) {
	testing.expect_value(t, visible_len(""), 0)
}

@(test)
test_visible_len_strips_ansi :: proc(t: ^testing.T) {
	// "\x1b[36m" (cyan) + "hi" + "\x1b[0m" (reset) — visible length is 2
	styled := "\x1b[36mhi\x1b[0m"
	testing.expect_value(t, visible_len(styled), 2)
}

@(test)
test_pad_right_visible_short_string :: proc(t: ^testing.T) {
	result := pad_right_visible("hi", 5)
	testing.expect_value(t, visible_len(result), 5)
}

@(test)
test_pad_right_visible_exact_width :: proc(t: ^testing.T) {
	result := pad_right_visible("hello", 5)
	testing.expect_value(t, result, "hello")
}

@(test)
test_pad_right_visible_already_wider :: proc(t: ^testing.T) {
	result := pad_right_visible("toolong", 3)
	testing.expect_value(t, result, "toolong")
}

@(test)
test_pad_right_visible_styled_string :: proc(t: ^testing.T) {
	// Styled "hi" (visible width 2) padded to 5 — result should have visible width 5
	styled := "\x1b[36mhi\x1b[0m"
	result := pad_right_visible(styled, 5)
	testing.expect_value(t, visible_len(result), 5)
}

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
