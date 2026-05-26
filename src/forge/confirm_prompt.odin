package forge

import "core:fmt"
import style "../style"
import components "../alloy-components"

ConfirmPromptState :: struct {
	using state: components.ConfirmState,
	label:       string,
}

confirm_prompt_init :: proc(label: string, default_yes: bool = true) -> ConfirmPromptState {
	return ConfirmPromptState{
		state = components.confirm_init(default_yes),
		label = label,
	}
}

confirm_prompt_update :: proc(state: ^ConfirmPromptState, msg: Msg) -> (StepResult, bool) {
	km, is_key := msg.(KeyMsg)
	if !is_key do return {}, false

	if km.key == .CtrlC {
		return StepResult{status = .Cancelled}, true
	}

	submitted := components.confirm_update(&state.state, km)
	if submitted {
		value := "Yes" if state.active else "No"
		return StepResult{value = value, status = .Done}, true
	}
	return {}, false
}

confirm_prompt_view :: proc(state: ConfirmPromptState) -> string {
	yes_style := style.DIM
	no_style  := style.DIM
	if state.active  do yes_style = style.CYAN
	if !state.active do no_style  = style.CYAN
	return fmt.tprintf("%sYes%s  /  %sNo%s\r\n",
		yes_style, style.RESET,
		no_style,  style.RESET,
	)
}

// run_confirm_prompt runs a complete confirm step and returns the result.
run_confirm_prompt :: proc(label: string, default_yes: bool = true) -> StepResult {
	state := confirm_prompt_init(label, default_yes)
	return run_step(
		state,
		proc(s: ^ConfirmPromptState, msg: Msg) -> (^ConfirmPromptState, StepResult, bool) {
			result, done := confirm_prompt_update(s, msg)
			return s, result, done
		},
		proc(s: ConfirmPromptState) -> string {
			return step_wrap_active(StepChrome{label = s.label}, confirm_prompt_view(s))
		},
	)
}
