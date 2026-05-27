package forge

import "core:fmt"
import "core:strings"
import style "../style"
import components "../alloy-components"

// MultiSelectOption is re-exported from components for caller convenience.
MultiSelectOption :: components.MultiSelectOption

MultiSelectPromptState :: struct {
	using state: components.MultiSelectState,
	label:       string,
	error:       string,
	validate:    proc([]string) -> string,
}

multi_select_prompt_init :: proc(label: string, options: []MultiSelectOption, validate: proc([]string) -> string = nil) -> MultiSelectPromptState {
	return MultiSelectPromptState{
		state    = components.multi_select_init(options),
		label    = label,
		validate = validate,
	}
}

multi_select_prompt_destroy :: proc(state: ^MultiSelectPromptState) {
	components.multi_select_destroy(&state.state)
}

multi_select_prompt_update :: proc(state: ^MultiSelectPromptState, msg: Msg) -> (StepResult, bool) {
	km, is_key := msg.(KeyMsg)
	if !is_key do return {}, false

	if km.key == .CtrlC {
		return StepResult{status = .Cancelled}, true
	}

	// Clear any previous validation error on navigation or toggle.
	if km.key != .Enter do state.error = ""

	submitted := components.multi_select_update(&state.state, km)
	if submitted {
		values := components.multi_select_selected(state.state)
		if state.validate != nil {
			err := state.validate(values)
			if err != "" {
				delete(values)
				state.error = err
				return {}, false
			}
		}
		labels := make([]string, len(values))
		for v, i in values {
			for opt in state.options {
				if opt.value == v {
					labels[i] = opt.label
					break
				}
			}
		}
		display := strings.join(labels, ", ")
		delete(labels)
		return StepResult{value = display, values = values, status = .Done}, true
	}
	return {}, false
}

multi_select_prompt_view :: proc(state: MultiSelectPromptState) -> string {
	buf: [dynamic]byte
	defer delete(buf)
	for option, index in state.options {
		checked := state.selected[index]
		focused := index == state.cursor
		glyph: string
		switch {
		case checked && focused:
			glyph = fmt.tprintf("%s◉%s", style.CYAN, style.RESET)
		case checked && !focused:
			glyph = fmt.tprintf("%s◎%s", style.GREEN, style.RESET)
		case !checked && focused:
			glyph = fmt.tprintf("%s●%s", style.CYAN, style.RESET)
		case:
			glyph = fmt.tprintf("%s○%s", style.DIM, style.RESET)
		}
		line: string
		if option.description != "" {
			line = fmt.tprintf(
				"%s %s  %s%s%s\r\n",
				glyph, option.label,
				style.DIM, option.description, style.RESET,
			)
		} else {
			line = fmt.tprintf("%s %s\r\n", glyph, option.label)
		}
		for b in transmute([]byte)line {append(&buf, b)}
	}
	view := fmt.tprintf("%s", string(buf[:]))
	if state.error != "" {
		return fmt.tprintf("%s%s%s%s", view, style.RED, state.error, style.RESET)
	}
	return view
}

// run_multi_select_prompt runs a complete multi-select step and returns the result.
// result.values holds the selected option values; result.value is the comma-joined labels.
// Options with default = true are pre-checked.
// Caller owns result.values — use step_result_destroy to free.
// validate is called on Enter; return a non-empty string to reject and show the error.
run_multi_select_prompt :: proc(label: string, options: []MultiSelectOption, validate: proc([]string) -> string = nil) -> StepResult {
	state := multi_select_prompt_init(label, options, validate)
	defer multi_select_prompt_destroy(&state)

	return run_step(
		state,
		proc(s: ^MultiSelectPromptState, msg: Msg) -> (^MultiSelectPromptState, StepResult, bool) {
			result, done := multi_select_prompt_update(s, msg)
			return s, result, done
		},
		proc(s: MultiSelectPromptState) -> string {
			return step_wrap_active(StepChrome{label = s.label}, multi_select_prompt_view(s))
		},
		proc(s: MultiSelectPromptState, result: StepResult) -> string {
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
