package main

import tui "./tui"
import "core:fmt"

AppModel :: struct {
	confirm: tui.Confirm,
	answer:  string,
}

app_init :: proc() -> (rawptr, tui.Cmd) {
	model := new(AppModel)
	tui.confirm_init(&model.confirm, "Delete all files?", false)
	model.answer = ""
	return model, nil
}

app_update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
	model := cast(^AppModel)raw

	if result, ok := tui.confirm_update(&model.confirm, msg).(tui.ConfirmMsg); ok {
		if result.confirmed {
			model.answer = "Yes"
		} else {
			model.answer = "No"
		}
		model.confirm.focused = false
	}

	if km, ok := msg.(tui.KeyMsg); ok {
		if km.key == .CtrlC do return raw, tui.quit
	}

	return raw, nil
}

app_view :: proc(raw: rawptr) -> string {
	model := cast(^AppModel)raw
	if model.answer != "" {
		return fmt.tprintf("Answer: %s\r\n\r\nPress Ctrl+C to quit.\r\n", model.answer)
	}
	return fmt.tprintf("%s\r\n", tui.confirm_view(model.confirm))
}

main :: proc() {
	tui.run(&tui.Program{init = app_init, update = app_update, view = app_view})
}
