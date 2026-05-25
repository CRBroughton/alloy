package tui

import "core:testing"

@(test)
test_buffer_write :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	buffer_write(&buf, "hello")
	testing.expect_value(t, buffer_string(&buf), "hello")
}

@(test)
test_buffer_writeln_adds_newline :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	buffer_writeln(&buf, "line")
	testing.expect_value(t, buffer_string(&buf), "line\n")
}

@(test)
test_buffer_write_multiple :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	buffer_write(&buf, "foo")
	buffer_write(&buf, "bar")
	buffer_write(&buf, "baz")
	testing.expect_value(t, buffer_string(&buf), "foobarbaz")
}

@(test)
test_buffer_writef :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	buffer_writef(&buf, "count: %d", 42)
	testing.expect_value(t, buffer_string(&buf), "count: 42")
}

@(test)
test_buffer_writef_multiple_args :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	buffer_writef(&buf, "%s=%d", "score", 100)
	testing.expect_value(t, buffer_string(&buf), "score=100")
}

@(test)
test_buffer_reset_clears_content :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	buffer_write(&buf, "some content")
	buffer_reset(&buf)
	testing.expect_value(t, buffer_string(&buf), "")
}

@(test)
test_buffer_reset_then_write :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	buffer_write(&buf, "old")
	buffer_reset(&buf)
	buffer_write(&buf, "new")
	testing.expect_value(t, buffer_string(&buf), "new")
}

@(test)
test_buffer_mixed_writes :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	buffer_writeln(&buf, "Line one")
	buffer_writef(&buf, "Count: %d\n", 42)
	buffer_write(&buf, "Done")

	testing.expect_value(t, buffer_string(&buf), "Line one\nCount: 42\nDone")
}

@(test)
test_buffer_empty_on_init :: proc(t: ^testing.T) {
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	testing.expect_value(t, buffer_string(&buf), "")
}
