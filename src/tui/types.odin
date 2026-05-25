package tui

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

Msg :: union {
	KeyMsg,
	WindowSizeMsg,
	QuitMsg,
}

Cmd :: #type proc() -> Msg

quit :: proc() -> Msg {
	return QuitMsg{}
}
