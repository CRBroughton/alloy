package forge


// run_step runs a single interactive step and returns its result.
// This is the core of Forge — compose multiple run_step calls for a wizard.
run_step :: proc(
	initial_state: $State,
	update: proc(state: ^State, msg: Msg) -> (^State, StepResult, bool),
	view: proc(state: State) -> string,
) -> StepResult {
	state := new_clone(initial_state)
	defer free(state)

	old_termios := raw_mode_enter()
	defer raw_mode_exit(old_termios)

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
			final := view(state^)
			cursor_up(last_line_count)
			render_locked(final)
			return result
		}
	}
}
