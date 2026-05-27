package components

MultiSelectOption :: struct {
	label:       string,
	value:       string,
	description: string,
	default:     bool,
}

MultiSelectState :: struct {
	options:  []MultiSelectOption,
	cursor:   int,
	selected: []bool,
}

multi_select_init :: proc(options: []MultiSelectOption) -> MultiSelectState {
	selected := make([]bool, len(options))
	for option, i in options {
		selected[i] = option.default
	}
	return MultiSelectState{options = options, cursor = 0, selected = selected}
}

multi_select_destroy :: proc(state: ^MultiSelectState) {
	delete(state.selected)
}

// multi_select_update handles navigation and toggling.
// Space toggles the focused option. Enter confirms.
// Returns true when Enter is pressed.
// CtrlC/cancel is not handled here — check before delegating.
multi_select_update :: proc(state: ^MultiSelectState, msg: KeyMsg) -> bool {
	#partial switch msg.key {
	case .Enter:
		return true
	case .Space:
		state.selected[state.cursor] = !state.selected[state.cursor]
	case .Up:
		if state.cursor > 0 do state.cursor -= 1
	case .Down:
		if state.cursor < len(state.options) - 1 do state.cursor += 1
	case .Home:
		state.cursor = 0
	case .End:
		state.cursor = len(state.options) - 1
	}
	return false
}

// multi_select_selected returns the values of all checked options.
// Caller owns the returned slice — call delete() when done.
multi_select_selected :: proc(state: MultiSelectState) -> []string {
	result: [dynamic]string
	for option, i in state.options {
		if state.selected[i] do append(&result, option.value)
	}
	return result[:]
}
