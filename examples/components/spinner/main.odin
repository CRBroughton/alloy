package main

import tui "../../../src/tui"
import "core:fmt"

Model :: struct {
	spinner: tui.Spinner,
}

init :: proc() -> (^Model, tui.Cmd) {
	m := new(Model)
	tui.spinner_init(&m.spinner, 1)
	m.spinner.label = "Working..."
	return m, tui.spinner_start(&m.spinner)
}

update :: proc(m: ^Model, msg: tui.Msg) -> (^Model, tui.Cmd) {
	if km, ok := msg.(tui.KeyMsg); ok && km.key == .CtrlC {
		return m, tui.quit
	}

	return m, tui.spinner_update(&m.spinner, msg)
}

view :: proc(m: ^Model) -> string {
	return fmt.tprintf("Spinner demo\r\n\r\n%s\r\n\r\nPress Ctrl+C to quit.\r\n", tui.spinner_view(m.spinner))
}

main :: proc() {
	tui.run(&tui.Program(Model){init = init, update = update, view = view})
}
