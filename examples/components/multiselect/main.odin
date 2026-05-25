package main

import tui "../../../src/tui"
import "core:fmt"
import "core:strings"

Model :: struct {
	sel:    tui.MultiSelect,
	chosen: string,
}

options := []tui.SelectionOption{
	{label = "Odin",   value = "odin"},
	{label = "C",      value = "c"},
	{label = "Go",     value = "go"},
	{label = "Rust",   value = "rust"},
	{label = "Zig",    value = "zig"},
}

init :: proc() -> (rawptr, tui.Cmd) {
	m := new(Model)
	tui.multiselect_init(&m.sel, options)
	return m, nil
}

update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
	m := cast(^Model)raw

	if km, ok := msg.(tui.KeyMsg); ok && km.key == .CtrlC {
		return raw, tui.quit
	}

	if result, ok := tui.multiselect_update(&m.sel, msg).(tui.MultiSelectDoneMsg); ok {
		m.chosen = strings.join(result.labels, ", ")
		delete(result.labels)
		delete(result.values)
		m.sel.focused = false
	}

	return raw, nil
}

view :: proc(raw: rawptr) -> string {
	m := cast(^Model)raw
	if m.chosen != "" {
		return fmt.tprintf("Chosen: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.chosen)
	}
	return fmt.tprintf(
		"MultiSelect demo\r\n\r\n%s\r\nSpace to toggle, Enter to confirm, Ctrl+C to quit.\r\n",
		tui.multiselect_view(m.sel),
	)
}

main :: proc() {
	tui.run(&tui.Program{init = init, update = update, view = view})
}
