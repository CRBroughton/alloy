package alloy

import style "../style"
import "core:fmt"

MultiSelect :: struct {
	options:        []SelectionOption, // borrowed — caller owns
	cursor:         int,
	selected:       []bool,            // owned — allocated by multiselect_init
	focused:        bool,
	_result_labels: [dynamic]string,   // owned — read via accessor after MultiSelectDoneMsg
	_result_values: [dynamic]string,
}

multiselect_init :: proc(s: ^MultiSelect, options: []SelectionOption) {
	s.options        = options
	s.cursor         = 0
	s.focused        = true
	s.selected       = make([]bool, len(options))
	s._result_labels = make([dynamic]string)
	s._result_values = make([dynamic]string)
}

multiselect_destroy :: proc(s: ^MultiSelect) {
	delete(s.selected)
	delete(s._result_labels)
	delete(s._result_values)
}

// multiselect_update handles keyboard input.
// Returns MultiSelectDoneMsg{} (signal only) on Enter.
// Read the selection via multiselect_selected_labels / multiselect_selected_values.
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
		clear(&s._result_labels)
		clear(&s._result_values)
		for sel, i in s.selected {
			if sel {
				append(&s._result_labels, s.options[i].label)
				append(&s._result_values, s.options[i].value)
			}
		}
		return MultiSelectDoneMsg{}
	}
	return nil
}

// multiselect_selected_labels returns selected labels.
// Valid until the next Enter keypress.
multiselect_selected_labels :: proc(s: ^MultiSelect) -> []string {
	return s._result_labels[:]
}

// multiselect_selected_values returns selected values.
// Valid until the next Enter keypress.
multiselect_selected_values :: proc(s: ^MultiSelect) -> []string {
	return s._result_values[:]
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
