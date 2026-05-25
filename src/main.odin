package main

import tui "./tui"
import "core:fmt"

colours := []tui.SelectionOption {
	{label = "Red", value = "red"},
	{label = "Green", value = "green"},
	{label = "Blue", value = "blue"},
	{label = "Yellow", value = "yellow"},
	{label = "Cyan", value = "cyan"},
}

AppModel :: struct {
	sel:    tui.Select,
	chosen: string,
}

app_init :: proc() -> (rawptr, tui.Cmd) {
	model := new(AppModel)
	tui.select_init(&model.sel, colours[:])
	return model, nil
}

app_update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
	model := cast(^AppModel)raw

	// Delegate to the component; handle any selection result directly
	if done, ok := tui.select_update(&model.sel, msg).(tui.SelectDoneMsg); ok {
		model.chosen = done.label
	}

	switch m in msg {
	case tui.KeyMsg:
		if m.key == .CtrlC do return raw, tui.quit
	case tui.SelectDoneMsg, tui.WindowSizeMsg, tui.QuitMsg:
	}

	return raw, nil
}

app_view :: proc(raw: rawptr) -> string {
	model := cast(^AppModel)raw
	header := "Choose a colour  (↑↓ navigate, Enter select, Ctrl+C quit)\r\n\r\n"
	list := tui.select_view(model.sel)
	footer := ""
	if model.chosen != "" {
		footer = fmt.tprintf("\r\nChosen: %s\r\n", model.chosen)
	}
	return fmt.tprintf("%s%s%s", header, list, footer)
}

main :: proc() {
	p := tui.Program {
		init   = app_init,
		update = app_update,
		view   = app_view,
	}
	tui.run(&p)
}
