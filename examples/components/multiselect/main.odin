package main

import alloy "../../../src/alloy"
import "core:fmt"
import "core:strings"

Model :: struct {
	sel:    alloy.MultiSelect,
	chosen: string,
}

options := []alloy.SelectionOption{
	{label = "Odin", value = "odin"},
	{label = "C",    value = "c"},
	{label = "Go",   value = "go"},
	{label = "Rust", value = "rust"},
	{label = "Zig",  value = "zig"},
}

init :: proc() -> (^Model, alloy.Cmd) {
	m := new(Model)
	alloy.multiselect_init(&m.sel, options)
	return m, nil
}

update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	if km, ok := msg.(alloy.KeyMsg); ok && km.key == .CtrlC {
		return m, alloy.quit
	}

	if _, ok := alloy.multiselect_update(&m.sel, msg).(alloy.MultiSelectDoneMsg); ok {
		labels := alloy.multiselect_selected_labels(&m.sel)
		m.chosen = strings.join(labels, ", ")
		m.sel.focused = false
	}

	return m, nil
}

view :: proc(m: ^Model) -> string {
	if m.chosen != "" {
		return fmt.tprintf("Chosen: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.chosen)
	}
	return fmt.tprintf(
		"MultiSelect demo\r\n\r\n%s\r\nSpace to toggle, Enter to confirm, Ctrl+C to quit.\r\n",
		alloy.multiselect_view(m.sel),
	)
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
