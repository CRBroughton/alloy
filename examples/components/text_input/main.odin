package main

import tui "../../../src/tui"
import "core:fmt"

Model :: struct {
	input:     tui.TextInput,
	submitted: string,
}

init :: proc() -> (^Model, tui.Cmd) {
	m := new(Model)
	tui.text_input_init(&m.input)
	m.input.placeholder = "Type something..."
	return m, nil
}

update :: proc(m: ^Model, msg: tui.Msg) -> (^Model, tui.Cmd) {
	if km, ok := msg.(tui.KeyMsg); ok {
		if km.key == .CtrlC do return m, tui.quit
		if km.key == .Enter && len(m.input.value) > 0 {
			m.submitted = tui.text_input_value(m.input)
			m.input.focused = false
		}
	}

	tui.text_input_update(&m.input, msg)
	return m, nil
}

view :: proc(m: ^Model) -> string {
	if m.submitted != "" {
		return fmt.tprintf("You typed: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.submitted)
	}
	return fmt.tprintf("TextInput demo\r\n\r\n%s\r\n\r\nPress Enter to submit, Ctrl+C to quit.\r\n", tui.text_input_view(m.input))
}

main :: proc() {
	tui.run(&tui.Program(Model){init = init, update = update, view = view})
}
