package alloy

import "core:testing"

@(test)
test_spinner_starts_inactive :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	testing.expect(t, !s.active, "spinner should be inactive after init")
}

@(test)
test_spinner_start_marks_active :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	spinner_start(&s)
	testing.expect(t, s.active, "spinner should be active after spinner_start")
}

@(test)
test_spinner_start_returns_cmd :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	cmd := spinner_start(&s)
	testing.expect(t, cmd != nil, "spinner_start should return a non-nil Cmd")
}

@(test)
test_spinner_start_returns_sleep_cmd :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	cmd := spinner_start(&s)
	_, ok := cmd.(SleepCmd)
	testing.expect(t, ok, "spinner_start should return a SleepCmd")
}

@(test)
test_spinner_tick_advances_frame :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	spinner_start(&s)

	initial_frame := s.frame
	spinner_update(&s, TickMsg{id = 1})
	testing.expect(t, s.frame != initial_frame, "frame should advance on TickMsg")
}

@(test)
test_spinner_tick_wraps_around :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	spinner_start(&s)

	n := len(s.frames)
	for _ in 0 ..< n {
		spinner_update(&s, TickMsg{id = 1})
	}
	// n ticks from frame 0 wraps back to 0
	testing.expect_value(t, s.frame, 0)
}

@(test)
test_spinner_tick_wrong_id_is_ignored :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 42)
	spinner_start(&s)

	initial_frame := s.frame
	cmd := spinner_update(&s, TickMsg{id = 99})

	testing.expect(t, s.frame == initial_frame, "wrong-id tick should not advance frame")
	testing.expect(t, cmd == nil, "wrong-id tick should return nil Cmd")
}

@(test)
test_spinner_stopped_ignores_tick :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	spinner_start(&s)
	spinner_stop(&s)

	initial_frame := s.frame
	cmd := spinner_update(&s, TickMsg{id = 1})

	testing.expect(t, s.frame == initial_frame, "stopped spinner should not advance frame")
	testing.expect(t, cmd == nil, "stopped spinner should return nil Cmd")
}

@(test)
test_spinner_tick_returns_next_cmd_when_active :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	spinner_start(&s)

	cmd := spinner_update(&s, TickMsg{id = 1})
	testing.expect(t, cmd != nil, "active spinner should return next tick Cmd")

	_, ok := cmd.(SleepCmd)
	testing.expect(t, ok, "next tick Cmd should be a SleepCmd")
}

@(test)
test_spinner_non_tick_msg_ignored :: proc(t: ^testing.T) {
	s: Spinner
	spinner_init(&s, 1)
	spinner_start(&s)

	initial_frame := s.frame
	cmd := spinner_update(&s, KeyMsg{key = .Enter})

	testing.expect(t, s.frame == initial_frame, "non-TickMsg should not advance frame")
	testing.expect(t, cmd == nil, "non-TickMsg should return nil Cmd")
}
