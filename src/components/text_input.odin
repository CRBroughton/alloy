package components

import "core:unicode/utf8"

TextInputState :: struct {
	value:       [dynamic]rune,
	cursor:      int,
	placeholder: string,
	mask:        bool,
}

text_input_init :: proc(placeholder: string = "") -> TextInputState {
	return TextInputState{
		value       = make([dynamic]rune),
		placeholder = placeholder,
	}
}

text_input_destroy :: proc(state: ^TextInputState) {
	delete(state.value)
}

// text_input_value returns the current content as a string.
// The caller owns the returned string and must delete it.
text_input_value :: proc(state: TextInputState) -> string {
	return utf8.runes_to_string(state.value[:])
}

// text_input_set replaces the content and moves the cursor to the end.
text_input_set :: proc(state: ^TextInputState, s: string) {
	clear(&state.value)
	for r in s {
		append(&state.value, r)
	}
	state.cursor = len(state.value)
}

// text_input_update handles editing keys. Returns true when Enter is pressed.
// CtrlC/cancel is not handled here — check before delegating.
text_input_update :: proc(state: ^TextInputState, msg: KeyMsg) -> bool {
	#partial switch msg.key {
	case .Enter:
		return true
	case .Rune:
		inject_at(&state.value, state.cursor, msg.rune)
		state.cursor += 1
	case .Backspace:
		if state.cursor > 0 {
			ordered_remove(&state.value, state.cursor - 1)
			state.cursor -= 1
		}
	case .Delete:
		if state.cursor < len(state.value) {
			ordered_remove(&state.value, state.cursor)
		}
	case .Left:
		if state.cursor > 0 do state.cursor -= 1
	case .Right:
		if state.cursor < len(state.value) do state.cursor += 1
	case .Home:
		state.cursor = 0
	case .End:
		state.cursor = len(state.value)
	case:
		// pass — Tab, Escape, etc. handled by caller
	}
	return false
}
