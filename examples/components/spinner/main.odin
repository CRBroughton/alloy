package main

import alloy "../../../src/alloy"
import "core:fmt"

Model :: struct {
	spinner: alloy.Spinner,
}

init :: proc() -> (^Model, alloy.Cmd) {
	m := new(Model)
	alloy.spinner_init(&m.spinner, 1)
	m.spinner.label = "Working..."
	return m, alloy.spinner_start(&m.spinner)
}

update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	if km, ok := msg.(alloy.KeyMsg); ok && km.key == .CtrlC {
		return m, alloy.quit
	}

	return m, alloy.spinner_update(&m.spinner, msg)
}

view :: proc(m: ^Model) -> string {
	return fmt.tprintf("Spinner demo\r\n\r\n%s\r\n\r\nPress Ctrl+C to quit.\r\n", alloy.spinner_view(m.spinner))
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
