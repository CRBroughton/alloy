package tui

import "core:testing"

// helper: build a Msg from a Key
key_msg :: proc(k: Key) -> Msg {
	return KeyMsg{key = k}
}

// helper: build a Msg from a rune
rune_msg :: proc(r: rune) -> Msg {
	return KeyMsg{key = .Rune, rune = r}
}

// ── insert ───────────────────────────────────────────────────────────────────

@(test)
test_text_input_insert_rune :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_update(&ti, rune_msg('h'))
	text_input_update(&ti, rune_msg('i'))

	v := text_input_value(ti)
	defer delete(v)
	testing.expect_value(t, v, "hi")
	testing.expect_value(t, ti.cursor, 2)
}

@(test)
test_text_input_insert_at_middle :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "ac")
	ti.cursor = 1 // position between 'a' and 'c'

	text_input_update(&ti, rune_msg('b'))

	v := text_input_value(ti)
	defer delete(v)
	testing.expect_value(t, v, "abc")
	testing.expect_value(t, ti.cursor, 2)
}

// ── backspace ────────────────────────────────────────────────────────────────

@(test)
test_text_input_backspace_deletes_before_cursor :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "hello")
	text_input_update(&ti, key_msg(.Backspace))

	v := text_input_value(ti)
	defer delete(v)
	testing.expect_value(t, v, "hell")
	testing.expect_value(t, ti.cursor, 4)
}

@(test)
test_text_input_backspace_at_start_is_noop :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "hi")
	ti.cursor = 0
	text_input_update(&ti, key_msg(.Backspace))

	v := text_input_value(ti)
	defer delete(v)
	testing.expect_value(t, v, "hi")
	testing.expect_value(t, ti.cursor, 0)
}

// ── delete ───────────────────────────────────────────────────────────────────

@(test)
test_text_input_delete_removes_at_cursor :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "hello")
	ti.cursor = 0
	text_input_update(&ti, key_msg(.Delete))

	v := text_input_value(ti)
	defer delete(v)
	testing.expect_value(t, v, "ello")
	testing.expect_value(t, ti.cursor, 0)
}

@(test)
test_text_input_delete_at_end_is_noop :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "hi") // cursor is at end (2)
	text_input_update(&ti, key_msg(.Delete))

	v := text_input_value(ti)
	defer delete(v)
	testing.expect_value(t, v, "hi")
}

// ── cursor movement ──────────────────────────────────────────────────────────

@(test)
test_text_input_left_moves_cursor :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "abc") // cursor = 3
	text_input_update(&ti, key_msg(.Left))
	testing.expect_value(t, ti.cursor, 2)
}

@(test)
test_text_input_left_at_start_is_noop :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "abc")
	ti.cursor = 0
	text_input_update(&ti, key_msg(.Left))
	testing.expect_value(t, ti.cursor, 0)
}

@(test)
test_text_input_right_moves_cursor :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "abc")
	ti.cursor = 0
	text_input_update(&ti, key_msg(.Right))
	testing.expect_value(t, ti.cursor, 1)
}

@(test)
test_text_input_right_at_end_is_noop :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "abc") // cursor = 3 = len
	text_input_update(&ti, key_msg(.Right))
	testing.expect_value(t, ti.cursor, 3)
}

@(test)
test_text_input_home_moves_to_start :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "hello") // cursor = 5
	text_input_update(&ti, key_msg(.Home))
	testing.expect_value(t, ti.cursor, 0)
}

@(test)
test_text_input_end_moves_to_end :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_set(&ti, "hello")
	ti.cursor = 0
	text_input_update(&ti, key_msg(.End))
	testing.expect_value(t, ti.cursor, 5)
}

// ── unicode ──────────────────────────────────────────────────────────────────

@(test)
test_text_input_unicode_runes :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	text_input_update(&ti, rune_msg('é'))
	text_input_update(&ti, rune_msg('à'))
	text_input_update(&ti, rune_msg('ñ'))

	v := text_input_value(ti)
	defer delete(v)
	testing.expect_value(t, v, "éàñ")
	testing.expect_value(t, ti.cursor, 3)
}

// ── unfocused ignores keys ───────────────────────────────────────────────────

@(test)
test_text_input_unfocused_ignores_keys :: proc(t: ^testing.T) {
	ti: TextInput
	text_input_init(&ti)
	defer text_input_destroy(&ti)

	ti.focused = false
	text_input_update(&ti, rune_msg('x'))

	v := text_input_value(ti)
	defer delete(v)
	testing.expect_value(t, v, "")
}
