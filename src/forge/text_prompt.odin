package forge

import "core:fmt"
import "core:strings"
import "core:unicode/utf8"
import style "../style"
import components "../components"

TextPromptState :: struct {
	using state: components.TextInputState,
	label:       string,
}

text_prompt_init :: proc(label: string, placeholder: string = "") -> TextPromptState {
	return TextPromptState{
		state = components.text_input_init(placeholder),
		label = label,
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

	submitted := components.text_input_update(&state.state, km)
	if submitted {
		value := components.text_input_value(state.state)
		return StepResult{value = value, status = .Done}, true
	}
	return {}, false
}

text_prompt_view :: proc(state: TextPromptState) -> string {
	if len(state.value) == 0 && state.placeholder != "" {
		return fmt.tprintf("%s%s%s", style.DIM, state.placeholder, style.RESET)
	}
	if state.mask {
		masked := strings.repeat("●", len(state.value))
		defer delete(masked)
		return fmt.tprintf("%s%s%s█", style.GREEN, masked, style.RESET)
	}
	before := utf8.runes_to_string(state.value[:state.cursor])
	after  := utf8.runes_to_string(state.value[state.cursor:])
	defer delete(before)
	defer delete(after)
	return fmt.tprintf("%s%s%s█%s", style.GREEN, before, style.RESET, after)
}

// run_text_prompt runs a complete text prompt step and returns the result.
run_text_prompt :: proc(label: string, placeholder: string = "") -> StepResult {
	state := text_prompt_init(label, placeholder)
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
	)
}
