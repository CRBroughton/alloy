package forge

import "core:fmt"
import style "../style"
import components "../alloy-components"

// SelectOption is re-exported from components for caller convenience.
SelectOption :: components.SelectOption

SelectPromptState :: struct {
	using state: components.SelectState,
	label:       string,
}

select_prompt_init :: proc(label: string, options: []SelectOption) -> SelectPromptState {
	return SelectPromptState{
		state = components.select_init(options),
		label = label,
	}
}

select_prompt_update :: proc(state: ^SelectPromptState, msg: Msg) -> (StepResult, bool) {
	km, is_key := msg.(KeyMsg)
	if !is_key do return {}, false

	if km.key == .CtrlC {
		return StepResult{status = .Cancelled}, true
	}

	submitted := components.select_update(&state.state, km)
	if submitted {
		chosen := components.select_selected(state.state)
		return StepResult{value = chosen.value, status = .Done}, true
	}
	return {}, false
}

select_prompt_view :: proc(state: SelectPromptState) -> string {
	buf: [dynamic]byte
	defer delete(buf)
	for option, index in state.options {
		line: string
		if index == state.cursor {
			line = fmt.tprintf("%s●%s %s\r\n", style.CYAN, style.RESET, option.label)
		} else {
			line = fmt.tprintf("%s○%s %s\r\n", style.DIM, style.RESET, option.label)
		}
		for b in transmute([]byte)line {
			append(&buf, b)
		}
	}
	return fmt.tprintf("%s", string(buf[:]))
}

// run_select_prompt runs a complete select step and returns the result.
run_select_prompt :: proc(label: string, options: []SelectOption) -> StepResult {
	state := select_prompt_init(label, options)
	return run_step(
		state,
		proc(s: ^SelectPromptState, msg: Msg) -> (^SelectPromptState, StepResult, bool) {
			result, done := select_prompt_update(s, msg)
			return s, result, done
		},
		proc(s: SelectPromptState) -> string {
			return step_wrap_active(StepChrome{label = s.label}, select_prompt_view(s))
		},
		proc(s: SelectPromptState, result: StepResult) -> string {
			chrome := StepChrome{label = s.label}
			switch result.status {
			case .Done:      return step_wrap_done(chrome, result.value)
			case .Cancelled: return step_wrap_cancelled(chrome)
			case .Error:     return step_wrap_error(chrome, result.value)
			case .Active:    unreachable()
			}
			return ""
		},
	)
}
