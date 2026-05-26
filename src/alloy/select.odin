package alloy

import style "../style"
import components "../components"
import "core:fmt"

// SelectionOption is an alias for the shared SelectOption type.
SelectionOption :: components.SelectOption

Select :: struct {
	using state:     components.SelectState,
	focused:         bool,
	cursor_prefix:   string,
	selected_prefix: string,
}

select_init :: proc(s: ^Select, options: []SelectionOption) {
	s.state = components.select_init(options)
	s.focused = true
	s.cursor_prefix = "› "
	s.selected_prefix = "✔ "
}

// select_update handles keyboard navigation for a Select component.
// Returns a SelectDoneMsg when the user confirms a selection, nil otherwise.
select_update :: proc(s: ^Select, msg: Msg) -> Msg {
	if !s.focused do return nil
	km, ok := msg.(KeyMsg)
	if !ok do return nil

	submitted := components.select_update(&s.state, km)
	if submitted {
		chosen := components.select_selected(s.state)
		return SelectDoneMsg{value = chosen.value, label = chosen.label}
	}
	return nil
}

select_view :: proc(s: Select) -> string {
	if len(s.options) == 0 {
		return fmt.tprintf("%s(no options)\r\n", style.DIM)
	}
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	for opt, i in s.options {
		if i == s.cursor && s.focused {
			buffer_writef(&buf, "%s%s%s%s\r\n", style.CYAN, s.cursor_prefix, opt.label, style.RESET)
		} else {
			buffer_writef(&buf, "  %s\r\n", opt.label)
		}
	}

	return fmt.tprintf("%s", buffer_string(&buf))
}
