package tui

import "core:fmt"
Confirm :: struct {
	prompt:      string,
	focused:     bool,
	default_yes: bool,
}

confirm_init :: proc(c: ^Confirm, prompt: string, default_yes: bool = false) {
	c.prompt = prompt
	c.focused = true
	c.default_yes = default_yes
}

confirm_update :: proc(c: ^Confirm, msg: Msg) -> Msg {
	if !c.focused do return nil

	km, ok := msg.(KeyMsg)
	if !ok do return nil

	#partial switch km.key {
	case .Enter:
		return ConfirmMsg{confirmed = c.default_yes}
	case .Rune:
		switch km.rune {
		case 'y', 'Y':
			return ConfirmMsg{confirmed = true}
		case 'n', 'N':
			return ConfirmMsg{confirmed = false}
		}
	}
	return nil
}


confirm_view :: proc(c: Confirm) -> string {
	hint := "[y/N]"
	if c.default_yes do hint = "[Y/n]"
	return fmt.tprintf("%s %s ", c.prompt, hint)
}
