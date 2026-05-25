package main

import tui "../../../src/tui"
import "core:fmt"

Model :: struct {
	spinner: tui.Spinner,
}

init :: proc() -> (rawptr, tui.Cmd) {
	m := new(Model)
	tui.spinner_init(&m.spinner, 1)
	m.spinner.label = "Working..."
	return m, tui.spinner_start(&m.spinner)
}

update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
	m := cast(^Model)raw

	if km, ok := msg.(tui.KeyMsg); ok && km.key == .CtrlC {
		return raw, tui.quit
	}

	return raw, tui.spinner_update(&m.spinner, msg)
}

view :: proc(raw: rawptr) -> string {
	m := cast(^Model)raw
	return fmt.tprintf("Spinner demo\r\n\r\n%s\r\n\r\nPress Ctrl+C to quit.\r\n", tui.spinner_view(m.spinner))
}

main :: proc() {
	tui.run(&tui.Program{init = init, update = update, view = view})
}
