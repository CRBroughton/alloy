package main

import tui "../../../src/tui"
import "core:fmt"

Model :: struct {
	sel:    tui.Select,
	chosen: string,
}

options := []tui.SelectionOption{
	{label = "Odin", value = "odin"},
	{label = "C",    value = "c"},
	{label = "Go",   value = "go"},
	{label = "Rust", value = "rust"},
}

init :: proc() -> (^Model, tui.Cmd) {
	m := new(Model)
	tui.select_init(&m.sel, options)
	return m, nil
}

update :: proc(m: ^Model, msg: tui.Msg) -> (^Model, tui.Cmd) {
	if km, ok := msg.(tui.KeyMsg); ok && km.key == .CtrlC {
		return m, tui.quit
	}

	if result, ok := tui.select_update(&m.sel, msg).(tui.SelectDoneMsg); ok {
		m.chosen = result.label
		m.sel.focused = false
	}

	return m, nil
}

view :: proc(m: ^Model) -> string {
	if m.chosen != "" {
		return fmt.tprintf("You chose: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.chosen)
	}
	return fmt.tprintf("Select demo\r\n\r\n%s\r\nPress Ctrl+C to quit.\r\n", tui.select_view(m.sel))
}

main :: proc() {
	tui.run(&tui.Program(Model){init = init, update = update, view = view})
}
