package main

import alloy "../../../src/alloy"
import "core:fmt"

Model :: struct {
	width:  int,
	height: int,
}

init :: proc() -> (^Model, alloy.Cmd) {
	m := new(Model)
	m.width = 80
	m.height = 24
	return m, nil
}

update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	#partial switch ev in msg {
	case alloy.WindowSizeMsg:
		m.width = ev.width
		m.height = ev.height
	case alloy.KeyMsg:
		if ev.key == .CtrlC do return m, alloy.quit
	}
	return m, nil
}

narrow_cols := []alloy.Track{alloy.Fr{1}}
wide_cols := []alloy.Track{alloy.Fr{1}, alloy.Fr{3}}

view :: proc(m: ^Model) -> string {
	g: alloy.Grid
	alloy.grid_init(&g, m.width)
	alloy.grid_gap(&g, 1)
	alloy.grid_breakpoint(
		&g,
		[]alloy.Breakpoint{
			{max_width = 80, columns = narrow_cols},
			{max_width = 999, columns = wide_cols},
		},
	)

	sidebar := fmt.tprintf(
		"Navigation\r\n──────────\r\nHome\r\nAbout\r\nContact\r\n\r\nWidth: %d",
		m.width,
	)
	content :=
		"Main Content\r\n────────────\r\nResize the terminal to see the layout change.\r\n< 80 cols: stacked\r\n> 80 cols: sidebar + main"

	return fmt.tprintf(
		"Responsive grid  (Ctrl+C to quit)\r\n\r\n%s",
		alloy.grid_view(g, alloy.cell(sidebar), alloy.cell(content)),
	)
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
