package main

import alloy "../../../src/alloy"
import "core:fmt"

Model :: struct {
	grid: alloy.Grid,
}

init :: proc() -> (^Model, alloy.Cmd) {
	m := new(Model)
	alloy.grid_init(&m.grid, 80)
	m.grid.template_columns = []alloy.Track{
		alloy.fr(1),
		alloy.fr(2),
		alloy.fr(1),
	}
	m.grid.column_gap = 2
	return m, nil
}

update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	if km, ok := msg.(alloy.KeyMsg); ok && km.key == .CtrlC {
		return m, alloy.quit
	}
	return m, nil
}

view :: proc(m: ^Model) -> string {
	col1 := "Name\r\nAlice\r\nBob\r\nCarol"
	col2 := "Role\r\nSenior Engineer\r\nProduct Manager\r\nDesigner"
	col3 := "Status\r\nActive\r\nActive\r\nAway"

	return fmt.tprintf(
		"Grid demo  (1fr | 2fr | 1fr, gap=2, width=80)\r\n\r\n%s\r\nCtrl+C to quit.\r\n",
		alloy.grid_view(m.grid, col1, col2, col3),
	)
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
