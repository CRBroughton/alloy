package tui

import style "../style"
import "core:fmt"

SelectionOption :: struct {
	label: string,
	value: string,
}

Select :: struct {
	options:         []SelectionOption,
	cursor:          int,
	focused:         bool,
	cursor_prefix:   string,
	selected_prefix: string,
}

select_init :: proc(s: ^Select, options: []SelectionOption) {
	s.options = options
	s.cursor = 0
	s.focused = true
	s.cursor_prefix = "› "
	s.selected_prefix = "✔ "
}

// select_update handles keyboard navigation for a Select component.
// Returns a SelectDoneMsg when the user confirms a selection, nil otherwise.
// Odin proc literals do not capture outer scope variables, so the selection
// result is returned as a Msg directly rather than wrapped in a Cmd.
select_update :: proc(s: ^Select, msg: Msg) -> Msg {
	if !s.focused do return nil

	km, ok := msg.(KeyMsg)
	if !ok do return nil

	#partial switch km.key {
	case .Up:
		s.cursor = max(s.cursor - 1, 0)
	case .Down:
		s.cursor = min(s.cursor + 1, len(s.options) - 1)
	case .Home:
		s.cursor = 0
	case .End:
		s.cursor = len(s.options) - 1
	case .Enter:
		if len(s.options) > 0 {
			chosen := s.options[s.cursor]
			return SelectDoneMsg{value = chosen.value, label = chosen.label}
		}
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
