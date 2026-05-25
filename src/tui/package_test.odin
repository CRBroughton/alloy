package tui

import "core:testing"
import "core:time"

// Smoke tests for the public API surface.

@(test)
test_program_struct_has_required_fields :: proc(t: ^testing.T) {
	p := Program(struct{}) {
		init   = nil,
		update = nil,
		view   = nil,
	}
	testing.expect(t, p.init == nil, "init field should be settable")
	testing.expect(t, p.update == nil, "update field should be settable")
	testing.expect(t, p.view == nil, "view field should be settable")
}

@(test)
test_quit_returns_quitmsg :: proc(t: ^testing.T) {
	msg := quit()
	_, ok := msg.(QuitMsg)
	testing.expect(t, ok, "quit() should return a QuitMsg")
}

@(test)
test_sleep_cmd_carries_data :: proc(t: ^testing.T) {
	cmd := Cmd(SleepCmd{duration = 100 * time.Millisecond, then = TickMsg{id = 7}})
	sc, ok := cmd.(SleepCmd)
	testing.expect(t, ok, "SleepCmd should be a valid Cmd variant")
	tick, is_tick := sc.then.(TickMsg)
	testing.expect(t, is_tick, "then field should hold a TickMsg")
	testing.expect_value(t, tick.id, 7)
}

@(test)
test_msg_union_accepts_all_types :: proc(t: ^testing.T) {
	msgs := [5]Msg {
		KeyMsg{key = .Enter},
		WindowSizeMsg{width = 80, height = 24},
		QuitMsg{},
		SelectDoneMsg{label = "A", value = "a"},
		TickMsg{id = 1},
	}
	testing.expect_value(t, len(msgs), 5)
}
