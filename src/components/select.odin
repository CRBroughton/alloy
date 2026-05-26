package components

SelectOption :: struct {
	label: string,
	value: string,
}

SelectState :: struct {
	options: []SelectOption,
	cursor:  int,
}

select_init :: proc(options: []SelectOption) -> SelectState {
	return SelectState{options = options, cursor = 0}
}

// select_update handles navigation. Returns true when Enter is pressed on a valid option.
// CtrlC/cancel is not handled here — check before delegating.
select_update :: proc(state: ^SelectState, msg: KeyMsg) -> bool {
	#partial switch msg.key {
	case .Enter:
		return len(state.options) > 0
	case .Up:
		if state.cursor > 0 do state.cursor -= 1
	case .Down:
		if state.cursor < len(state.options) - 1 do state.cursor += 1
	case .Home:
		state.cursor = 0
	case .End:
		state.cursor = len(state.options) - 1
	case:
		// pass
	}
	return false
}

// select_selected returns the currently highlighted option.
select_selected :: proc(state: SelectState) -> SelectOption {
	return state.options[state.cursor]
}
