package components

import "core:testing"

test_multi_select_options := []MultiSelectOption{
	{label = "Alpha", value = "alpha"},
	{label = "Beta",  value = "beta"},
	{label = "Gamma", value = "gamma"},
}

@(test)
test_multi_select_init_all_unchecked :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	for checked in state.selected {
		testing.expect(t, !checked, "all options should start unchecked")
	}
}

@(test)
test_multi_select_init_respects_defaults :: proc(t: ^testing.T) {
	options := []MultiSelectOption{
		{label = "Alpha", value = "alpha", default = true},
		{label = "Beta",  value = "beta",  default = false},
		{label = "Gamma", value = "gamma", default = true},
	}
	state := multi_select_init(options[:])
	defer multi_select_destroy(&state)
	testing.expect(t,  state.selected[0], "alpha should start checked (default = true)")
	testing.expect(t, !state.selected[1], "beta should start unchecked (default = false)")
	testing.expect(t,  state.selected[2], "gamma should start checked (default = true)")
}

@(test)
test_multi_select_space_toggles_on :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	multi_select_update(&state, KeyMsg{key = .Space})
	testing.expect(t, state.selected[0], "Space should check focused option")
}

@(test)
test_multi_select_space_toggles_off :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	multi_select_update(&state, KeyMsg{key = .Space})
	multi_select_update(&state, KeyMsg{key = .Space})
	testing.expect(t, !state.selected[0], "second Space should uncheck option")
}

@(test)
test_multi_select_space_toggles_default_off :: proc(t: ^testing.T) {
	options := []MultiSelectOption{
		{label = "Alpha", value = "alpha", default = true},
	}
	state := multi_select_init(options[:])
	defer multi_select_destroy(&state)
	multi_select_update(&state, KeyMsg{key = .Space})
	testing.expect(t, !state.selected[0], "Space should uncheck a default-true option")
}

@(test)
test_multi_select_space_only_toggles_focused :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	state.cursor = 1
	multi_select_update(&state, KeyMsg{key = .Space})
	testing.expect(t, !state.selected[0], "option 0 should stay unchecked")
	testing.expect(t,  state.selected[1], "option 1 should be checked")
	testing.expect(t, !state.selected[2], "option 2 should stay unchecked")
}

@(test)
test_multi_select_down :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	multi_select_update(&state, KeyMsg{key = .Down})
	testing.expect_value(t, state.cursor, 1)
}

@(test)
test_multi_select_up :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	state.cursor = 2
	multi_select_update(&state, KeyMsg{key = .Up})
	testing.expect_value(t, state.cursor, 1)
}

@(test)
test_multi_select_up_clamps_at_zero :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	multi_select_update(&state, KeyMsg{key = .Up})
	testing.expect_value(t, state.cursor, 0)
}

@(test)
test_multi_select_down_clamps_at_last :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	state.cursor = len(test_multi_select_options) - 1
	multi_select_update(&state, KeyMsg{key = .Down})
	testing.expect_value(t, state.cursor, len(test_multi_select_options) - 1)
}

@(test)
test_multi_select_home :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	state.cursor = 2
	multi_select_update(&state, KeyMsg{key = .Home})
	testing.expect_value(t, state.cursor, 0)
}

@(test)
test_multi_select_end :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	multi_select_update(&state, KeyMsg{key = .End})
	testing.expect_value(t, state.cursor, len(test_multi_select_options) - 1)
}

@(test)
test_multi_select_enter_returns_true :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	submitted := multi_select_update(&state, KeyMsg{key = .Enter})
	testing.expect(t, submitted, "Enter should return true")
}

@(test)
test_multi_select_selected_returns_checked_values :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	state.selected[0] = true
	state.selected[2] = true
	values := multi_select_selected(state)
	defer delete(values)
	testing.expect_value(t, len(values), 2)
	testing.expect_value(t, values[0], "alpha")
	testing.expect_value(t, values[1], "gamma")
}

@(test)
test_multi_select_selected_empty_when_none_checked :: proc(t: ^testing.T) {
	state := multi_select_init(test_multi_select_options[:])
	defer multi_select_destroy(&state)
	values := multi_select_selected(state)
	defer delete(values)
	testing.expect_value(t, len(values), 0)
}

@(test)
test_multi_select_selected_includes_defaults :: proc(t: ^testing.T) {
	options := []MultiSelectOption{
		{label = "Alpha", value = "alpha", default = true},
		{label = "Beta",  value = "beta"},
	}
	state := multi_select_init(options[:])
	defer multi_select_destroy(&state)
	values := multi_select_selected(state)
	defer delete(values)
	testing.expect_value(t, len(values), 1)
	testing.expect_value(t, values[0], "alpha")
}
