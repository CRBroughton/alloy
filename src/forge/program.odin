package forge

import "core:fmt"
import "core:strings"

_forge_started := false
_forge_locked: strings.Builder

// run_step runs a single interactive step and returns its result.
// On the first call the alternate screen is entered — it stays open across all
// steps so the cursor never jumps around on the main screen.  wizard_end
// closes it and prints the accumulated output to the main screen.
run_step :: proc(
	initial_state: $State,
	update: proc(state: ^State, msg: Msg) -> (^State, StepResult, bool),
	view: proc(state: State) -> string,
	view_done: proc(state: State, result: StepResult) -> string,
) -> StepResult {
	state := new_clone(initial_state)
	defer free(state)

	if !_forge_started {
		strings.builder_init(&_forge_locked)
		// Enter alternate screen once for the whole wizard.
		fmt.printf("\x1b[?1049h\x1b[2J\x1b[H\x1b[?25l")
		_forge_started = true
	}

	old_termios := raw_mode_enter()

	last_line_count := 0

	for {
		rendered := view(state^)
		cursor_up(last_line_count)
		render_inline(rendered)
		last_line_count = count_lines(rendered)

		msg := read_key()

		new_state, result, done := update(state, msg)
		state = new_state

		if done {
			cursor_up(last_line_count)
			raw_mode_exit(old_termios)
			locked := view_done(state^, result)
			render_locked(locked)
			strings.write_string(&_forge_locked, locked)
			return result
		}
	}
}
