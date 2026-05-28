package alloy

import "core:strings"
import "core:testing"

// --- visible_len ---

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

// --- pad_right_visible ---

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

// --- truncate ---

@(test)
test_truncate_short_string :: proc(t: ^testing.T) {
	result := truncate("Hello", 10)
	testing.expect_value(t, result, "Hello")
}

@(test)
test_truncate_exact_width :: proc(t: ^testing.T) {
	result := truncate("Hello", 5)
	testing.expect_value(t, result, "Hello")
}

@(test)
test_truncate_long_string_correct_length :: proc(t: ^testing.T) {
	result := truncate("Hello world", 7)
	testing.expect_value(t, visible_len(result), 7)
}

@(test)
test_truncate_ends_with_ellipsis :: proc(t: ^testing.T) {
	result := truncate("Hello world", 7)
	testing.expect(t, strings.has_suffix(result, "…"), "truncate should end with ellipsis")
}

// --- wrap ---

@(test)
test_wrap_short :: proc(t: ^testing.T) {
	result := wrap("Hello", 20)
	testing.expect_value(t, result, "Hello")
}

@(test)
test_wrap_breaks_at_width :: proc(t: ^testing.T) {
	result := wrap("one two three four five", 10)
	testing.expect(t, strings.contains(result, "\r\n"), "wrap should insert line breaks")
}

@(test)
test_wrap_each_line_within_width :: proc(t: ^testing.T) {
	result := wrap("one two three four five six seven", 12)
	lines := strings.split(result, "\r\n")
	defer delete(lines)
	for line in lines {
		testing.expect(t, visible_len(line) <= 12, "every line should fit within width")
	}
}
