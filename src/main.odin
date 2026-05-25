package main

import "core:fmt"
import tui "./tui"

AppModel :: struct {
	spinner: tui.Spinner,
	done:    bool,
}

app_init :: proc() -> (rawptr, tui.Cmd) {
	model := new(AppModel)
	tui.spinner_init(&model.spinner, id = 1)
	model.spinner.label = "Working on something..."
	cmd := tui.spinner_start(&model.spinner)
	return model, cmd
}

app_update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
	model := cast(^AppModel)raw

	// Route tick to spinner; returns the next SleepCmd while active
	if cmd := tui.spinner_update(&model.spinner, msg); cmd != nil {
		return raw, cmd
	}

	switch m in msg {
	case tui.KeyMsg:
		#partial switch m.key {
		case .Enter:
			tui.spinner_stop(&model.spinner)
			model.done = true
		case .CtrlC:
			return raw, tui.quit
		}
	case tui.TickMsg, tui.SelectDoneMsg, tui.WindowSizeMsg, tui.QuitMsg:
	}

	return raw, nil
}

app_view :: proc(raw: rawptr) -> string {
	model := cast(^AppModel)raw
	if model.done {
		return "Done!\r\n\r\nPress Ctrl+C to exit.\r\n"
	}
	return fmt.tprintf(
		"Spinner Demo\r\n\r\n%s\r\n\r\nPress Enter to finish, Ctrl+C to quit.\r\n",
		tui.spinner_view(model.spinner),
	)
}

main :: proc() {
	p := tui.Program{
		init   = app_init,
		update = app_update,
		view   = app_view,
	}
	tui.run(&p)
}
