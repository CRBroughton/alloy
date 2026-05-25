package main

import alloy "../../src/alloy"
import "core:fmt"

Model :: struct {
	count: int,
}

init :: proc() -> (^Model, alloy.Cmd) {
	return new(Model), nil
}

update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
	if km, ok := msg.(alloy.KeyMsg); ok {
		if km.key == .CtrlC                    do return m, alloy.quit
		if km.key == .Rune && km.rune == '+' do m.count += 1
		if km.key == .Rune && km.rune == '-' do m.count -= 1
	}
	return m, nil
}

view :: proc(m: ^Model) -> string {
	return fmt.tprintf("Count: %d  (+ to increment, - to decrement, Ctrl+C to quit)\r\n", m.count)
}

main :: proc() {
	alloy.run(&alloy.Program(Model){init = init, update = update, view = view})
}
