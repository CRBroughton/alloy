package alloy

import "core:testing"

test_ms_options := []SelectionOption {
	{label = "Alpha", value = "alpha"},
	{label = "Beta", value = "beta"},
	{label = "Gamma", value = "gamma"},
}

ms_key :: proc(k: Key) -> Msg {return KeyMsg{key = k}}
ms_space :: proc() -> Msg {return KeyMsg{key = .Rune, rune = ' '}}

@(test)
test_multiselect_down_moves_cursor :: proc(t: ^testing.T) {
	s: MultiSelect
	multiselect_init(&s, test_ms_options[:])
	defer multiselect_destroy(&s)

	multiselect_update(&s, ms_key(.Down))
	testing.expect_value(t, s.cursor, 1)
}

@(test)
test_multiselect_up_clamps_at_zero :: proc(t: ^testing.T) {
	s: MultiSelect
	multiselect_init(&s, test_ms_options[:])
	defer multiselect_destroy(&s)

	multiselect_update(&s, ms_key(.Up))
	testing.expect_value(t, s.cursor, 0)
}

@(test)
test_multiselect_space_toggles_selection :: proc(t: ^testing.T) {
	s: MultiSelect
	multiselect_init(&s, test_ms_options[:])
	defer multiselect_destroy(&s)

	testing.expect(t, !s.selected[0], "should start unselected")
	multiselect_update(&s, ms_space())
	testing.expect(t, s.selected[0], "Space should select the item")
	multiselect_update(&s, ms_space())
	testing.expect(t, !s.selected[0], "Space again should deselect")
}

@(test)
test_multiselect_multiple_selections :: proc(t: ^testing.T) {
	s: MultiSelect
	multiselect_init(&s, test_ms_options[:])
	defer multiselect_destroy(&s)

	// Select item 0
	multiselect_update(&s, ms_space())
	// Move to item 2 and select
	multiselect_update(&s, ms_key(.Down))
	multiselect_update(&s, ms_key(.Down))
	multiselect_update(&s, ms_space())

	testing.expect(t, s.selected[0], "item 0 should be selected")
	testing.expect(t, !s.selected[1], "item 1 should not be selected")
	testing.expect(t, s.selected[2], "item 2 should be selected")
}

@(test)
test_multiselect_enter_returns_selected :: proc(t: ^testing.T) {
	s: MultiSelect
	multiselect_init(&s, test_ms_options[:])
	defer multiselect_destroy(&s)

	multiselect_update(&s, ms_key(.Down))
	multiselect_update(&s, ms_space())

	result := multiselect_update(&s, ms_key(.Enter))
	_, ok := result.(MultiSelectDoneMsg)
	testing.expect(t, ok, "Enter should return MultiSelectDoneMsg")

	values := multiselect_selected_values(&s)
	labels := multiselect_selected_labels(&s)
	testing.expect_value(t, len(values), 1)
	testing.expect_value(t, values[0], "beta")
	testing.expect_value(t, labels[0], "Beta")
}

@(test)
test_multiselect_enter_empty_selection :: proc(t: ^testing.T) {
	s: MultiSelect
	multiselect_init(&s, test_ms_options[:])
	defer multiselect_destroy(&s)

	result := multiselect_update(&s, ms_key(.Enter))
	_, ok := result.(MultiSelectDoneMsg)
	testing.expect(t, ok, "Enter should return MultiSelectDoneMsg even with nothing selected")
	testing.expect_value(t, len(multiselect_selected_values(&s)), 0)
}

@(test)
test_multiselect_unfocused_ignores_input :: proc(t: ^testing.T) {
	s: MultiSelect
	multiselect_init(&s, test_ms_options[:])
	defer multiselect_destroy(&s)
	s.focused = false

	multiselect_update(&s, ms_key(.Down))
	testing.expect_value(t, s.cursor, 0)
}
