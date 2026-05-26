package components

import "core:testing"

@(test)
test_confirm_default_yes :: proc(t: ^testing.T) {
	state := confirm_init(true)
	testing.expect(t, state.active, "default yes should set active = true")
}

@(test)
test_confirm_default_no :: proc(t: ^testing.T) {
	state := confirm_init(false)
	testing.expect(t, !state.active, "default no should set active = false")
}

@(test)
test_confirm_enter_submits :: proc(t: ^testing.T) {
	state := confirm_init(true)
	submitted := confirm_update(&state, KeyMsg{key = .Enter})
	testing.expect(t, submitted, "Enter should return true")
	testing.expect(t, state.active, "active should remain true")
}

@(test)
test_confirm_left_toggles :: proc(t: ^testing.T) {
	state := confirm_init(true)
	confirm_update(&state, KeyMsg{key = .Left})
	testing.expect(t, !state.active, "Left should toggle to false")
}

@(test)
test_confirm_right_toggles :: proc(t: ^testing.T) {
	state := confirm_init(false)
	confirm_update(&state, KeyMsg{key = .Right})
	testing.expect(t, state.active, "Right should toggle to true")
}

@(test)
test_confirm_tab_toggles :: proc(t: ^testing.T) {
	state := confirm_init(true)
	confirm_update(&state, KeyMsg{key = .Tab})
	testing.expect(t, !state.active, "Tab should toggle")
}

@(test)
test_confirm_y_submits_yes :: proc(t: ^testing.T) {
	state := confirm_init(false)
	submitted := confirm_update(&state, KeyMsg{key = .Rune, rune = 'y'})
	testing.expect(t, submitted, "y should submit")
	testing.expect(t, state.active, "y should set active = true")
}

@(test)
test_confirm_n_submits_no :: proc(t: ^testing.T) {
	state := confirm_init(true)
	submitted := confirm_update(&state, KeyMsg{key = .Rune, rune = 'n'})
	testing.expect(t, submitted, "n should submit")
	testing.expect(t, !state.active, "n should set active = false")
}

@(test)
test_confirm_capital_y :: proc(t: ^testing.T) {
	state := confirm_init(false)
	submitted := confirm_update(&state, KeyMsg{key = .Rune, rune = 'Y'})
	testing.expect(t, submitted, "Y should submit")
	testing.expect(t, state.active, "Y should set active = true")
}

@(test)
test_confirm_other_key_no_submit :: proc(t: ^testing.T) {
	state := confirm_init(true)
	submitted := confirm_update(&state, KeyMsg{key = .Rune, rune = 'x'})
	testing.expect(t, !submitted, "x should not submit")
}
