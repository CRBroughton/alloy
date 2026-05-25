package tui

import style "../style"
import "core:fmt"

MultiSelect :: struct {
	options:  []SelectionOption,
	cursor:   int,
	selected: []bool,
	focused:  bool,
}

multiselect_init :: proc(s: ^MultiSelect, options: []SelectionOption) {
	s.options = options
	s.cursor = 0
	s.focused = true
	s.selected = make([]bool, len(options))
}

multiselect_destroy :: proc(s: ^MultiSelect) {
	delete(s.selected)
}

multiselect_update :: proc(s: ^MultiSelect, msg: Msg) -> Msg {
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
	case .Rune:
		if km.rune == ' ' && len(s.options) > 0 {
			s.selected[s.cursor] = !s.selected[s.cursor]
		}
	case .Enter:
		labels := make([dynamic]string)
		values := make([dynamic]string)
		for selected, i in s.selected {
			if selected {
				append(&labels, s.options[i].label)
				append(&values, s.options[i].value)

			}
		}
		return MultiSelectDoneMsg{labels = labels[:], values = values[:]}
	}
	return nil
}

multiselect_view :: proc(s: MultiSelect) -> string {
	if len(s.options) == 0 {
		return fmt.tprintf("%s(no options)\r\n", style.DIM)
	}
	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	for opt, i in s.options {
		checked := "[ ]"
		if s.selected[i] do checked = "[✔]"

		if i == s.cursor && s.focused {
			buffer_writef(&buf, "%s› %s %s%s\r\n", style.CYAN, checked, opt.label, style.RESET)
		} else {
			buffer_writef(&buf, "  %s %s\r\n", checked, opt.label)
		}
	}

	return fmt.tprintf("%s", buffer_string(&buf))
}
