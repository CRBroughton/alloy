package forge

import "core:testing"

@(test)
test_count_lines_empty :: proc(t: ^testing.T) {
	testing.expect_value(t, count_lines(""), 0)
}

@(test)
test_count_lines_single :: proc(t: ^testing.T) {
	// no newline — cursor stays on the same line, no cursor_up needed
	testing.expect_value(t, count_lines("hello"), 0)
}

@(test)
test_count_lines_two_lines :: proc(t: ^testing.T) {
	// one \n — cursor advanced one line
	testing.expect_value(t, count_lines("line one\nline two"), 1)
}

@(test)
test_count_lines_three_lines :: proc(t: ^testing.T) {
	// two \n — cursor advanced two lines
	testing.expect_value(t, count_lines("a\nb\nc"), 2)
}

@(test)
test_count_lines_trailing_newline :: proc(t: ^testing.T) {
	// two \n — cursor advanced two lines (trailing newline is a cursor advance)
	testing.expect_value(t, count_lines("a\nb\n"), 2)
}

@(test)
test_count_lines_crlf :: proc(t: ^testing.T) {
	// \r\n — only \n increments count; two \r\n = two cursor advances
	testing.expect_value(t, count_lines("a\r\nb\r\n"), 2)
}
