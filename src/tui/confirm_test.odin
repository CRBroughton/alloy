package tui

import "core:testing"

@(test)
test_confirm_y_returns_true :: proc(t: ^testing.T) {
	c: Confirm
	confirm_init(&c, "Continue?")

	result := confirm_update(&c, KeyMsg{key = .Rune, rune = 'y'})
	msg, ok := result.(ConfirmMsg)
	testing.expect(t, ok, "y should return a ConfirmMsg")
	testing.expect(t, msg.confirmed, "y should set confirmed = true")
}

@(test)
test_confirm_uppercase_y_returns_true :: proc(t: ^testing.T) {
	c: Confirm
	confirm_init(&c, "Continue?")

	result := confirm_update(&c, KeyMsg{key = .Rune, rune = 'Y'})
	msg, ok := result.(ConfirmMsg)
	testing.expect(t, ok, "Y should return a ConfirmMsg")
	testing.expect(t, msg.confirmed, "Y should set confirmed = true")
}

@(test)
test_confirm_n_returns_false :: proc(t: ^testing.T) {
	c: Confirm
	confirm_init(&c, "Continue?")

	result := confirm_update(&c, KeyMsg{key = .Rune, rune = 'n'})
	msg, ok := result.(ConfirmMsg)
	testing.expect(t, ok, "n should return a ConfirmMsg")
	testing.expect(t, !msg.confirmed, "n should set confirmed = false")
}

@(test)
test_confirm_enter_uses_default :: proc(t: ^testing.T) {
	c: Confirm
	confirm_init(&c, "Continue?", true) // default_yes = true

	result := confirm_update(&c, KeyMsg{key = .Enter})
	msg, ok := result.(ConfirmMsg)
	testing.expect(t, ok, "Enter should return a ConfirmMsg")
	testing.expect(t, msg.confirmed, "Enter should use the default (true)")
}

@(test)
test_confirm_enter_default_no :: proc(t: ^testing.T) {
	c: Confirm
	confirm_init(&c, "Continue?", false) // default_yes = false

	result := confirm_update(&c, KeyMsg{key = .Enter})
	msg, ok := result.(ConfirmMsg)
	testing.expect(t, ok, "Enter should return a ConfirmMsg")
	testing.expect(t, !msg.confirmed, "Enter should use the default (false)")
}

@(test)
test_confirm_other_key_returns_nil :: proc(t: ^testing.T) {
	c: Confirm
	confirm_init(&c, "Continue?")

	result := confirm_update(&c, KeyMsg{key = .Rune, rune = 'x'})
	testing.expect(t, result == nil, "unrecognised key should return nil")
}

@(test)
test_confirm_unfocused_ignores_input :: proc(t: ^testing.T) {
	c: Confirm
	confirm_init(&c, "Continue?")
	c.focused = false

	result := confirm_update(&c, KeyMsg{key = .Rune, rune = 'y'})
	testing.expect(t, result == nil, "unfocused confirm should return nil")
}
