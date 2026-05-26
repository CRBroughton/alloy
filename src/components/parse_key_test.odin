package components

import "core:testing"

@(test)
test_parse_key_ctrl_c :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x03})
	testing.expect_value(t, km.key, Key.CtrlC)
}

@(test)
test_parse_key_ctrl_d :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x04})
	testing.expect_value(t, km.key, Key.CtrlD)
}

@(test)
test_parse_key_enter :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x0D})
	testing.expect_value(t, km.key, Key.Enter)
}

@(test)
test_parse_key_backspace :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x7F})
	testing.expect_value(t, km.key, Key.Backspace)
}

@(test)
test_parse_key_tab :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x09})
	testing.expect_value(t, km.key, Key.Tab)
}

@(test)
test_parse_key_escape_alone :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B})
	testing.expect_value(t, km.key, Key.Escape)
}

@(test)
test_parse_key_arrow_up :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', 'A'})
	testing.expect_value(t, km.key, Key.Up)
}

@(test)
test_parse_key_arrow_down :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', 'B'})
	testing.expect_value(t, km.key, Key.Down)
}

@(test)
test_parse_key_arrow_right :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', 'C'})
	testing.expect_value(t, km.key, Key.Right)
}

@(test)
test_parse_key_arrow_left :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', 'D'})
	testing.expect_value(t, km.key, Key.Left)
}

@(test)
test_parse_key_rune_ascii :: proc(t: ^testing.T) {
	km := parse_key([]byte{'a'})
	testing.expect_value(t, km.key, Key.Rune)
	testing.expect_value(t, km.rune, rune('a'))
}

@(test)
test_parse_key_delete :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', '3', '~'})
	testing.expect_value(t, km.key, Key.Delete)
}

@(test)
test_parse_key_home :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', 'H'})
	testing.expect_value(t, km.key, Key.Home)
}

@(test)
test_parse_key_end :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', 'F'})
	testing.expect_value(t, km.key, Key.End)
}

@(test)
test_parse_key_page_up :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', '5', '~'})
	testing.expect_value(t, km.key, Key.PageUp)
}

@(test)
test_parse_key_page_down :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x1B, '[', '6', '~'})
	testing.expect_value(t, km.key, Key.PageDown)
}

@(test)
test_parse_key_ctrl_l :: proc(t: ^testing.T) {
	km := parse_key([]byte{0x0C})
	testing.expect_value(t, km.key, Key.CtrlL)
}

@(test)
test_parse_key_empty :: proc(t: ^testing.T) {
	km := parse_key([]byte{})
	testing.expect_value(t, km.key, Key.Unknown)
}
