package alloy

import components "../alloy-components"
import "core:fmt"

Confirm :: struct {
	using state: components.ConfirmState,
	prompt:      string,
	focused:     bool,
}

confirm_init :: proc(c: ^Confirm, prompt: string, default_yes: bool = false) {
	c.state = components.confirm_init(default_yes)
	c.prompt = prompt
	c.focused = true
}

confirm_update :: proc(c: ^Confirm, msg: Msg) -> Msg {
	if !c.focused do return nil
	km, ok := msg.(KeyMsg)
	if !ok do return nil

	submitted := components.confirm_update(&c.state, km)
	if submitted {
		return ConfirmMsg{confirmed = c.active}
	}
	return nil
}

confirm_view :: proc(c: Confirm) -> string {
	hint := "[y/N]"
	if c.active do hint = "[Y/n]"
	return fmt.tprintf("%s %s ", c.prompt, hint)
}
