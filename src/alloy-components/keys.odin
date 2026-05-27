package components

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
	Space,
}

KeyMsg :: struct {
	key:  Key,
	rune: rune,
}
