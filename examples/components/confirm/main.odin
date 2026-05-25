package main

import tui "../../../src/alloy"
import "core:fmt"

Model :: struct {
	confirm: tui.Confirm,
	answer:  string,
}

init :: proc() -> (^Model, tui.Cmd) {
	m := new(Model)
	tui.confirm_init(&m.confirm, "Delete all files?", false)
	return m, nil
}

update :: proc(m: ^Model, msg: tui.Msg) -> (^Model, tui.Cmd) {
	if km, ok := msg.(tui.KeyMsg); ok && km.key == .CtrlC {
		return m, tui.quit
	}

	if result, ok := tui.confirm_update(&m.confirm, msg).(tui.ConfirmMsg); ok {
		m.answer = result.confirmed ? "Yes" : "No"
		m.confirm.focused = false
	}

	return m, nil
}

view :: proc(m: ^Model) -> string {
	if m.answer != "" {
		return fmt.tprintf("Answer: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.answer)
	}
	return fmt.tprintf("Confirm demo\r\n\r\n%s\r\n", tui.confirm_view(m.confirm))
}

main :: proc() {
	tui.run(&tui.Program(Model){init = init, update = update, view = view})
}
