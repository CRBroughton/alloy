package main

import alloy "../../../src/alloy"
import "core:fmt"

Model :: struct {
	sel:    alloy.Select,
	chosen: string,
}

options := []alloy.SelectionOption{
	{label = "Odin", value = "odin"},
	{label = "C",    value = "c"},
	{label = "Go",   value = "go"},
	{label = "Rust", value = "rust"},
}

init :: proc() -> (^Model, alloy.Cmd) {
	m := new(Model)
	alloy.select_init(&m.sel, options)
	return m, nil
}

update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	if km, ok := msg.(alloy.KeyMsg); ok && km.key == .CtrlC {
		return m, alloy.quit
	}

	if result, ok := alloy.select_update(&m.sel, msg).(alloy.SelectDoneMsg); ok {
		m.chosen = result.label
		m.sel.focused = false
	}

	return m, nil
}

view :: proc(m: ^Model) -> string {
	if m.chosen != "" {
		return fmt.tprintf("You chose: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.chosen)
	}
	return fmt.tprintf("Select demo\r\n\r\n%s\r\nPress Ctrl+C to quit.\r\n", alloy.select_view(m.sel))
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
