package components

import "core:testing"

@(test)
test_text_input_insert_rune :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	text_input_update(&state, KeyMsg{key = .Rune, rune = 'h'})
	text_input_update(&state, KeyMsg{key = .Rune, rune = 'i'})

	v := text_input_value(state)
	defer delete(v)
	testing.expect_value(t, v, "hi")
	testing.expect_value(t, state.cursor, 2)
}

@(test)
test_text_input_insert_at_middle :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	text_input_set(&state, "ac")
	state.cursor = 1

	text_input_update(&state, KeyMsg{key = .Rune, rune = 'b'})

	v := text_input_value(state)
	defer delete(v)
	testing.expect_value(t, v, "abc")
	testing.expect_value(t, state.cursor, 2)
}

@(test)
test_text_input_backspace :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	text_input_set(&state, "hello")
	text_input_update(&state, KeyMsg{key = .Backspace})

	v := text_input_value(state)
	defer delete(v)
	testing.expect_value(t, v, "hell")
	testing.expect_value(t, state.cursor, 4)
}

@(test)
test_text_input_backspace_at_start_noop :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	text_input_set(&state, "hi")
	state.cursor = 0
	text_input_update(&state, KeyMsg{key = .Backspace})

	v := text_input_value(state)
	defer delete(v)
	testing.expect_value(t, v, "hi")
	testing.expect_value(t, state.cursor, 0)
}

@(test)
test_text_input_delete :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	text_input_set(&state, "hello")
	state.cursor = 0
	text_input_update(&state, KeyMsg{key = .Delete})

	v := text_input_value(state)
	defer delete(v)
	testing.expect_value(t, v, "ello")
}

@(test)
test_text_input_left_right :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	text_input_set(&state, "abc")
	text_input_update(&state, KeyMsg{key = .Left})
	testing.expect_value(t, state.cursor, 2)
	text_input_update(&state, KeyMsg{key = .Right})
	testing.expect_value(t, state.cursor, 3)
}

@(test)
test_text_input_home_end :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	text_input_set(&state, "hello")
	text_input_update(&state, KeyMsg{key = .Home})
	testing.expect_value(t, state.cursor, 0)
	text_input_update(&state, KeyMsg{key = .End})
	testing.expect_value(t, state.cursor, 5)
}

@(test)
test_text_input_enter_returns_true :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	submitted := text_input_update(&state, KeyMsg{key = .Enter})
	testing.expect(t, submitted, "Enter should return true")
}

@(test)
test_text_input_other_keys_return_false :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	submitted := text_input_update(&state, KeyMsg{key = .Rune, rune = 'a'})
	testing.expect(t, !submitted, "Rune should return false")
}

@(test)
test_text_input_placeholder :: proc(t: ^testing.T) {
	state := text_input_init("my-app")
	defer text_input_destroy(&state)

	testing.expect_value(t, state.placeholder, "my-app")
}

@(test)
test_text_input_unicode :: proc(t: ^testing.T) {
	state := text_input_init()
	defer text_input_destroy(&state)

	text_input_update(&state, KeyMsg{key = .Rune, rune = 'é'})
	text_input_update(&state, KeyMsg{key = .Rune, rune = 'à'})

	v := text_input_value(state)
	defer delete(v)
	testing.expect_value(t, v, "éà")
	testing.expect_value(t, state.cursor, 2)
}
