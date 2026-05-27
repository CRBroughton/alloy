package forge

import "core:fmt"
import "core:strings"
import "core:unicode/utf8"
import style "../style"
import components "../alloy-components"

TextPromptState :: struct {
	using state: components.TextInputState,
	label:       string,
	error:       string,
	validate:    proc(string) -> string,
}

text_prompt_init :: proc(label: string, placeholder: string = "", validate: proc(string) -> string = nil) -> TextPromptState {
	return TextPromptState{
		state    = components.text_input_init(placeholder),
		label    = label,
		validate = validate,
	}
}

text_prompt_destroy :: proc(state: ^TextPromptState) {
	components.text_input_destroy(&state.state)
}

text_prompt_update :: proc(state: ^TextPromptState, msg: Msg) -> (StepResult, bool) {
	km, is_key := msg.(KeyMsg)
	if !is_key do return {}, false

	if km.key == .CtrlC {
		return StepResult{status = .Cancelled}, true
	}

	// Clear any previous validation error on the next keystroke.
	state.error = ""

	submitted := components.text_input_update(&state.state, km)
	if submitted {
		value := components.text_input_value(state.state)
		if state.validate != nil {
			err := state.validate(value)
			if err != "" {
				state.error = err
				return {}, false
			}
		}
		return StepResult{value = value, status = .Done}, true
	}
	return {}, false
}

text_prompt_view :: proc(state: TextPromptState) -> string {
	input: string
	if len(state.value) == 0 && state.placeholder != "" {
		input = fmt.tprintf("%s%s%s", style.DIM, state.placeholder, style.RESET)
	} else if state.mask {
		masked := strings.repeat("●", len(state.value))
		defer delete(masked)
		input = fmt.tprintf("%s%s%s█", style.GREEN, masked, style.RESET)
	} else {
		before := utf8.runes_to_string(state.value[:state.cursor])
		after  := utf8.runes_to_string(state.value[state.cursor:])
		defer delete(before)
		defer delete(after)
		input = fmt.tprintf("%s%s%s█%s", style.GREEN, before, style.RESET, after)
	}
	if state.error != "" {
		return fmt.tprintf("%s\r\n%s%s%s", input, style.RED, state.error, style.RESET)
	}
	return input
}

// run_text_prompt runs a complete text prompt step and returns the result.
// validate is called on submit; return a non-empty string to reject and show the error.
run_text_prompt :: proc(label: string, placeholder: string = "", validate: proc(string) -> string = nil) -> StepResult {
	state := text_prompt_init(label, placeholder, validate)
	defer text_prompt_destroy(&state)

	return run_step(
		state,
		proc(s: ^TextPromptState, msg: Msg) -> (^TextPromptState, StepResult, bool) {
			result, done := text_prompt_update(s, msg)
			return s, result, done
		},
		proc(s: TextPromptState) -> string {
			return step_wrap_active(StepChrome{label = s.label}, text_prompt_view(s))
		},
		proc(s: TextPromptState, result: StepResult) -> string {
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
