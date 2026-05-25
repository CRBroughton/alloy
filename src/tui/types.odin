package tui

import "core:time"

Key :: enum {
	Unknown,
	Rune,
	Up,
	Down,
	Left,
	Right,
	Home,
	End,
	PageUp,
	PageDown,
	Enter,
	Backspace,
	Delete,
	Tab,
	Escape,
	CtrlC,
	CtrlD,
	CtrlL,
}

KeyMsg :: struct {
	key:  Key,
	rune: rune,
}

WindowSizeMsg :: struct {
	width:  int,
	height: int,
}

QuitMsg :: struct {}
TickMsg :: struct {
	id: int,
}
SelectDoneMsg :: struct {
	label, value: string,
}

// SleepCmd is a Cmd that pauses for `duration` then delivers `then` to the loop.
// Use this wherever you need timer-driven updates (spinners, debounced input, etc.)
// Odin proc literals cannot capture outer-scope variables, so timed commands
// carry their data here rather than inside a closure.
SleepCmd :: struct {
	duration: time.Duration,
	then:     Msg,
}

ConfirmMsg :: struct {
	confirmed: bool,
}

MultiSelectDoneMsg :: struct {
	labels: []string,
	values: []string,
}

Msg :: union {
	KeyMsg,
	WindowSizeMsg,
	QuitMsg,
	SelectDoneMsg,
	MultiSelectDoneMsg,
	TickMsg,
	ConfirmMsg,
}

// Cmd is either:
//   proc() -> Msg   — a function run on a background thread
//   SleepCmd        — sleep for a duration, then deliver a Msg
// nil means no command.
Cmd :: union {
	proc() -> Msg,
	SleepCmd,
}

quit :: proc() -> Msg {
	return QuitMsg{}
}

// sleep returns a Cmd that waits duration then delivers then to the event loop.
sleep :: proc(duration: time.Duration, then: Msg) -> Cmd {
	return SleepCmd{duration = duration, then = then}
}
