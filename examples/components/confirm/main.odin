package main

import alloy "../../../src/alloy"
import "core:fmt"

Model :: struct {
	confirm: alloy.Confirm,
	answer:  string,
}

init :: proc() -> (^Model, alloy.Cmd) {
	m := new(Model)
	alloy.confirm_init(&m.confirm, "Delete all files?", false)
	return m, nil
}

update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	if km, ok := msg.(alloy.KeyMsg); ok && km.key == .CtrlC {
		return m, alloy.quit
	}

	if result, ok := alloy.confirm_update(&m.confirm, msg).(alloy.ConfirmMsg); ok {
		m.answer = result.confirmed ? "Yes" : "No"
		m.confirm.focused = false
	}

	return m, nil
}

view :: proc(m: ^Model) -> string {
	if m.answer != "" {
		return fmt.tprintf("Answer: %s\r\n\r\nPress Ctrl+C to quit.\r\n", m.answer)
	}
	return fmt.tprintf("Confirm demo\r\n\r\n%s\r\n", alloy.confirm_view(m.confirm))
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
