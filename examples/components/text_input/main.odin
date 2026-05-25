package main

import alloy "../../../src/alloy"
import "core:fmt"

Model :: struct {
	input:     alloy.TextInput,
	submitted: string,
}

init :: proc() -> (^Model, alloy.Cmd) {
	m := new(Model)
	alloy.text_input_init(&m.input)
	m.input.placeholder = "Type something..."
	return m, nil
}

update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	if km, ok := msg.(alloy.KeyMsg); ok {
		if km.key == .CtrlC do return m, alloy.quit
		if km.key == .Enter && len(m.input.value) > 0 {
			m.submitted = alloy.text_input_value(m.input)
			m.input.focused = false
		}
	}

	alloy.text_input_update(&m.input, msg)
	return m, nil
}

view :: proc(m: ^Model) -> string {
	if m.submitted != "" {
		return fmt.tprintf("You typed: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.submitted)
	}
	return fmt.tprintf("TextInput demo\r\n\r\n%s\r\n\r\nPress Enter to submit, Ctrl+C to quit.\r\n", alloy.text_input_view(m.input))
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
