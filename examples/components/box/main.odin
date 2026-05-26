package main

import alloy "../../../src/alloy"
import "core:fmt"

Model :: struct {
	style_index: int,
	focused:     bool,
}

styles := []alloy.BoxStyle{.Rounded, .Single, .Double, .Heavy}
labels := []string{"Rounded", "Single", "Double", "Heavy"}

init :: proc() -> (^Model, alloy.Cmd) {
	model := new(Model)
	model.focused = true
	return model, nil
}

update :: proc(model: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	if km, ok := msg.(alloy.KeyMsg); ok {
		#partial switch km.key {
		case .CtrlC:
			return model, alloy.quit
		case .Left:
			model.style_index = (model.style_index - 1 + len(styles)) % len(styles)
		case .Right:
			model.style_index = (model.style_index + 1) % len(styles)
		case .Tab:
			model.focused = !model.focused
		}
	}
	return model, nil
}

view :: proc(model: ^Model) -> string {
	box := alloy.Box {
		title   = labels[model.style_index],
		width   = 30,
		border  = styles[model.style_index],
		focused = model.focused,
	}
	content := []string{"Line 1 of content", "Line 2 of content", "Line 3 of content"}
	return fmt.tprintf(
		"Box demo\r\n\r\n%s\r\n← → cycle style, Tab toggle focus, Ctrl+C quit.\r\n",
		alloy.box_render(box, content),
	)
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
