package components

ConfirmState :: struct {
	active: bool, // true = Yes
}

confirm_init :: proc(default_yes: bool = true) -> ConfirmState {
	return ConfirmState{active = default_yes}
}

// confirm_update handles toggle and submit. Returns true when submitted.
// y/n shortcuts set active and immediately submit.
// CtrlC/cancel is not handled here — check before delegating.
confirm_update :: proc(state: ^ConfirmState, msg: KeyMsg) -> bool {
	#partial switch msg.key {
	case .Enter:
		return true
	case .Left, .Right, .Tab:
		state.active = !state.active
	case .Rune:
		switch msg.rune {
		case 'y', 'Y':
			state.active = true
			return true
		case 'n', 'N':
			state.active = false
			return true
		}
	case:
		// pass
	}
	return false
}
