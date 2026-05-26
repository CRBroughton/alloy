package components

import "core:testing"

test_select_options := []SelectOption{
	{label = "Alpha", value = "alpha"},
	{label = "Beta",  value = "beta"},
	{label = "Gamma", value = "gamma"},
}

@(test)
test_select_down :: proc(t: ^testing.T) {
	state := select_init(test_select_options[:])
	select_update(&state, KeyMsg{key = .Down})
	testing.expect_value(t, state.cursor, 1)
}

@(test)
test_select_up :: proc(t: ^testing.T) {
	state := select_init(test_select_options[:])
	state.cursor = 2
	select_update(&state, KeyMsg{key = .Up})
	testing.expect_value(t, state.cursor, 1)
}

@(test)
test_select_up_clamps_at_zero :: proc(t: ^testing.T) {
	state := select_init(test_select_options[:])
	select_update(&state, KeyMsg{key = .Up})
	testing.expect_value(t, state.cursor, 0)
}

@(test)
test_select_down_clamps_at_last :: proc(t: ^testing.T) {
	state := select_init(test_select_options[:])
	state.cursor = len(test_select_options) - 1
	select_update(&state, KeyMsg{key = .Down})
	testing.expect_value(t, state.cursor, len(test_select_options) - 1)
}

@(test)
test_select_home :: proc(t: ^testing.T) {
	state := select_init(test_select_options[:])
	state.cursor = 2
	select_update(&state, KeyMsg{key = .Home})
	testing.expect_value(t, state.cursor, 0)
}

@(test)
test_select_end :: proc(t: ^testing.T) {
	state := select_init(test_select_options[:])
	select_update(&state, KeyMsg{key = .End})
	testing.expect_value(t, state.cursor, len(test_select_options) - 1)
}

@(test)
test_select_enter_returns_true :: proc(t: ^testing.T) {
	state := select_init(test_select_options[:])
	state.cursor = 1
	submitted := select_update(&state, KeyMsg{key = .Enter})
	testing.expect(t, submitted, "Enter should return true")
}

@(test)
test_select_selected :: proc(t: ^testing.T) {
	state := select_init(test_select_options[:])
	state.cursor = 1
	chosen := select_selected(state)
	testing.expect_value(t, chosen.value, "beta")
	testing.expect_value(t, chosen.label, "Beta")
}

@(test)
test_select_enter_empty_returns_false :: proc(t: ^testing.T) {
	state := select_init([]SelectOption{})
	submitted := select_update(&state, KeyMsg{key = .Enter})
	testing.expect(t, !submitted, "Enter on empty options should return false")
}
