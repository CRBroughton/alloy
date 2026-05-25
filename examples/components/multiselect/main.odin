package main

import tui "../../../src/alloy"
import "core:fmt"
import "core:strings"

Model :: struct {
	sel:    tui.MultiSelect,
	chosen: string,
}

options := []tui.SelectionOption{
	{label = "Odin", value = "odin"},
	{label = "C",    value = "c"},
	{label = "Go",   value = "go"},
	{label = "Rust", value = "rust"},
	{label = "Zig",  value = "zig"},
}

init :: proc() -> (^Model, tui.Cmd) {
	m := new(Model)
	tui.multiselect_init(&m.sel, options)
	return m, nil
}

update :: proc(m: ^Model, msg: tui.Msg) -> (^Model, tui.Cmd) {
	if km, ok := msg.(tui.KeyMsg); ok && km.key == .CtrlC {
		return m, tui.quit
	}

	if _, ok := tui.multiselect_update(&m.sel, msg).(tui.MultiSelectDoneMsg); ok {
		labels := tui.multiselect_selected_labels(&m.sel)
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
		tui.multiselect_view(m.sel),
	)
}

main :: proc() {
	tui.run(&tui.Program(Model){init = init, update = update, view = view})
}
