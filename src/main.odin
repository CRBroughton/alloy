package main

import tui "./tui"
import "core:fmt"

AppModel :: struct {
	input:     tui.TextInput,
	submitted: string,
}

app_init :: proc() -> (rawptr, tui.Cmd) {
	model := new(AppModel)
	tui.text_input_init(&model.input)
	model.input.placeholder = "Type something..."
	model.input.prompt = "› "
	return model, nil
}

app_update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
	model := cast(^AppModel)raw

	// Let the text input handle most keys
	tui.text_input_update(&model.input, msg)

	// Handle keys the parent cares about
	if km, ok := msg.(tui.KeyMsg); ok {
		#partial switch km.key {
		case .Enter:
			model.submitted = tui.text_input_value(model.input)
			tui.text_input_set(&model.input, "")
		case .CtrlC:
			return raw, tui.quit
		case:
		}
	}

	return raw, nil
}

app_view :: proc(raw: rawptr) -> string {
	model := cast(^AppModel)raw
	header := "Text Input Demo  (Enter to submit, Ctrl+C to quit)\r\n\r\n"
	input := tui.text_input_view(model.input)
	submitted := ""
	if model.submitted != "" {
		submitted = fmt.tprintf("\r\n\r\nLast submitted: %s", model.submitted)
	}
	return fmt.tprintf("%s%s%s\r\n", header, input, submitted)
}

main :: proc() {
	p := tui.Program {
		init   = app_init,
		update = app_update,
		view   = app_view,
	}
	tui.run(&p)
}
