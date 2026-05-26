package forge

import "core:testing"

@(test)
test_count_lines_empty :: proc(t: ^testing.T) {
	testing.expect_value(t, count_lines(""), 0)
}

@(test)
test_count_lines_single :: proc(t: ^testing.T) {
	testing.expect_value(t, count_lines("hello"), 1)
}

@(test)
test_count_lines_two_lines :: proc(t: ^testing.T) {
	testing.expect_value(t, count_lines("line one\nline two"), 2)
}

@(test)
test_count_lines_three_lines :: proc(t: ^testing.T) {
	testing.expect_value(t, count_lines("a\nb\nc"), 3)
}

@(test)
test_count_lines_trailing_newline :: proc(t: ^testing.T) {
	// trailing \n counts as an extra line
	testing.expect_value(t, count_lines("a\nb\n"), 3)
}

@(test)
test_count_lines_crlf :: proc(t: ^testing.T) {
	// \r\n — only \n increments count
	testing.expect_value(t, count_lines("a\r\nb\r\n"), 3)
}
