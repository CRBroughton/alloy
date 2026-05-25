package style

import "core:strings"
import "core:testing"

@(test)
test_colorize_wraps_with_escape_codes :: proc(t: ^testing.T) {
	result := colorise("hello", GREEN)

	// Should start with the colour code
	testing.expect(
		t,
		strings.has_prefix(result, GREEN),
		"colorize: result should start with colour code",
	)

	// Should end with reset
	testing.expect(t, strings.has_suffix(result, RESET), "colorize: result should end with RESET")

	// The original text should appear in the middle
	testing.expect(
		t,
		strings.contains(result, "hello"),
		"colorize: result should contain the original text",
	)
}

@(test)
test_colorize_preserves_text :: proc(t: ^testing.T) {
	// colorize should not alter the text content itself
	result := colorise("World", BLUE)
	expected := strings.concatenate([]string{BLUE, "World", RESET})
	defer delete(expected)

	testing.expect_value(t, result, expected)
}

@(test)
test_colorize_empty_string :: proc(t: ^testing.T) {
	result := colorise("", RED)
	expected := strings.concatenate([]string{RED, "", RESET})
	defer delete(expected)

	testing.expect_value(t, result, expected)
}

@(test)
test_colorize_different_colors :: proc(t: ^testing.T) {
	// Each colour constant should produce a distinct result
	red_result := colorise("x", RED)
	green_result := colorise("x", GREEN)
	blue_result := colorise("x", BLUE)

	testing.expect(t, red_result != green_result, "red and green should differ")
	testing.expect(t, green_result != blue_result, "green and blue should differ")
	testing.expect(t, red_result != blue_result, "red and blue should differ")
}
