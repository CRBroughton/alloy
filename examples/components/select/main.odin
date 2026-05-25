package main

import tui "../../../src/tui"
import "core:fmt"

Model :: struct {
	sel:    tui.Select,
	chosen: string,
}

options := []tui.SelectionOption{
	{label = "Odin", value = "odin"},
	{label = "C", value = "c"},
	{label = "Go", value = "go"},
	{label = "Rust", value = "rust"},
}

init :: proc() -> (rawptr, tui.Cmd) {
	m := new(Model)
	tui.select_init(&m.sel, options)
	return m, nil
}

update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
	m := cast(^Model)raw

	if km, ok := msg.(tui.KeyMsg); ok && km.key == .CtrlC {
		return raw, tui.quit
	}

	if result, ok := tui.select_update(&m.sel, msg).(tui.SelectDoneMsg); ok {
		m.chosen = result.label
		m.sel.focused = false
	}

	return raw, nil
}

view :: proc(raw: rawptr) -> string {
	m := cast(^Model)raw
	if m.chosen != "" {
		return fmt.tprintf("You chose: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.chosen)
	}
	return fmt.tprintf("Select demo\r\n\r\n%s\r\nPress Ctrl+C to quit.\r\n", tui.select_view(m.sel))
}

main :: proc() {
	tui.run(&tui.Program{init = init, update = update, view = view})
}
