package tui

import "core:testing"

sel_key_msg :: proc(k: Key) -> Msg {
	return KeyMsg{key = k}
}

test_options := []SelectionOption {
	{label = "Alpha", value = "alpha"},
	{label = "Beta", value = "beta"},
	{label = "Gamma", value = "gamma"},
	{label = "Delta", value = "delta"},
}

@(test)
test_select_down_increments_cursor :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])

	select_update(&s, sel_key_msg(.Down))
	testing.expect_value(t, s.cursor, 1)
}

@(test)
test_select_up_decrements_cursor :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])
	s.cursor = 2

	select_update(&s, sel_key_msg(.Up))
	testing.expect_value(t, s.cursor, 1)
}

@(test)
test_select_up_clamps_at_zero :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])

	select_update(&s, sel_key_msg(.Up))
	testing.expect_value(t, s.cursor, 0)
}

@(test)
test_select_down_clamps_at_last :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])
	s.cursor = len(test_options) - 1

	select_update(&s, sel_key_msg(.Down))
	testing.expect_value(t, s.cursor, len(test_options) - 1)
}

@(test)
test_select_home_moves_to_first :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])
	s.cursor = 3

	select_update(&s, sel_key_msg(.Home))
	testing.expect_value(t, s.cursor, 0)
}

@(test)
test_select_end_moves_to_last :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])

	select_update(&s, sel_key_msg(.End))
	testing.expect_value(t, s.cursor, len(test_options) - 1)
}

@(test)
test_select_enter_returns_done_msg :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])
	s.cursor = 1 // "Beta"

	msg := select_update(&s, sel_key_msg(.Enter))
	done, ok := msg.(SelectDoneMsg)
	testing.expect(t, ok, "Enter on a valid option should return a SelectDoneMsg")
	testing.expect_value(t, done.value, "beta")
	testing.expect_value(t, done.label, "Beta")
}

@(test)
test_select_enter_correct_item_at_different_cursor :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])
	s.cursor = 3 // "Delta"

	msg := select_update(&s, sel_key_msg(.Enter))
	done, ok := msg.(SelectDoneMsg)
	testing.expect(t, ok, "Enter should return a SelectDoneMsg")
	testing.expect_value(t, done.value, "delta")
	testing.expect_value(t, done.label, "Delta")
}

@(test)
test_select_unfocused_ignores_keys :: proc(t: ^testing.T) {
	s: Select
	select_init(&s, test_options[:])
	s.focused = false

	select_update(&s, sel_key_msg(.Down))
	testing.expect_value(t, s.cursor, 0)
}
