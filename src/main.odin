package main

import tui "./tui"
import "core:fmt"

AppModel :: struct {
	count:   int,
	message: string,
}

app_init :: proc() -> (rawptr, tui.Cmd) {
	model := new(AppModel)
	model.count = 0
	model.message = "Press + to increment, q to quit"
	return model, nil
}

app_update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
	model := cast(^AppModel)raw

	switch m in msg {
	case tui.KeyMsg:
		#partial switch m.key {
		case .Rune:
			if m.rune == '+' do model.count += 1
			if m.rune == 'q' do return raw, tui.quit
		case .CtrlC:
			return raw, tui.quit
		case:
		// ignore
		}
	case tui.WindowSizeMsg, tui.QuitMsg:
	// ignore for now
	}
	return raw, nil
}

app_view :: proc(raw: rawptr) -> string {
	model := cast(^AppModel)raw
	return fmt.tprintf("%s\n\nCount: %d\n", model.message, model.count)
}

main :: proc() {
	p := tui.Program {
		init   = app_init,
		update = app_update,
		view   = app_view,
	}
	tui.run(&p)
}
