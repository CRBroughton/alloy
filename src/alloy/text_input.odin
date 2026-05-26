package alloy

import style "../style"
import components "../alloy-components"
import "core:fmt"
import "core:unicode/utf8"

// TextInput is a single-line text editor with a cursor.
TextInput :: struct {
	using state: components.TextInputState,
	// alloy-specific display options:
	prompt:      string,
	width:       int, // 0 = unlimited
	focused:     bool,
	cursor_char: rune, // default '█'
}

// text_input_init initialises a TextInput with sensible defaults.
text_input_init :: proc(t: ^TextInput) {
	t.state = components.text_input_init()
	t.focused = true
	t.cursor_char = '█'
	t.prompt = "> "
}

// text_input_destroy frees the dynamic array.
text_input_destroy :: proc(t: ^TextInput) {
	components.text_input_destroy(&t.state)
}

// text_input_value returns the current text content as a string.
// The caller owns the returned string and must delete it.
text_input_value :: proc(t: TextInput) -> string {
	return components.text_input_value(t.state)
}

// text_input_set sets the content and moves the cursor to the end.
text_input_set :: proc(t: ^TextInput, s: string) {
	components.text_input_set(&t.state, s)
}

// text_input_update handles a Msg and returns an optional Cmd.
text_input_update :: proc(t: ^TextInput, msg: Msg) -> Cmd {
	if !t.focused do return nil
	key_msg, ok := msg.(KeyMsg)
	if !ok do return nil
	// Enter/CtrlC handled at model level; delegate editing ops to components.
	components.text_input_update(&t.state, key_msg)
	return nil
}

// text_input_view renders the text input to a string.
text_input_view :: proc(t: TextInput) -> string {
	if len(t.value) == 0 && !t.focused {
		if t.placeholder != "" {
			return fmt.tprintf("%s%s%s%s", t.prompt, style.DIM, t.placeholder, style.RESET)
		}
		return t.prompt
	}

	before := utf8.runes_to_string(t.value[:t.cursor])
	after  := utf8.runes_to_string(t.value[t.cursor:])
	defer delete(before)
	defer delete(after)

	if t.focused {
		return fmt.tprintf(
			"%s%s%s%c%s%s%s",
			t.prompt,
			style.GREEN,
			before,
			t.cursor_char,
			after,
			style.RESET,
			"",
		)
	}

	return fmt.tprintf("%s%s%s", t.prompt, before, after)
}
