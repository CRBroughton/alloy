package tui

Program :: struct {
	init:   proc() -> (rawptr, Cmd),
	update: proc(model: rawptr, msg: Msg) -> (rawptr, Cmd),
	view:   proc(model: rawptr) -> string,
}

run :: proc(p: ^Program) {
	panic("not yet implemented")
}
