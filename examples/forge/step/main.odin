package main

import "core:fmt"
import forge "../../../src/forge"

// Demonstrates Step chrome rendering without a real interactive prompt.
// Shows all four states: active, done, error, cancelled — then wizard_end.
main :: proc() {
	active_chrome  := forge.StepChrome{label = "Project name?"}
	done_chrome    := forge.StepChrome{label = "Framework?"}
	error_chrome   := forge.StepChrome{label = "Package manager?"}
	cancel_chrome  := forge.StepChrome{label = "Install dependencies?"}

	// Active step — shown while user is typing
	fmt.print(forge.step_wrap_active(active_chrome, "my-app"))

	// Done step — locked after user confirms
	fmt.print(forge.step_wrap_done(done_chrome, "React"))

	// Error step — shown when validation fails
	fmt.print(forge.step_wrap_error(error_chrome, "unsupported package manager"))

	// Cancelled step — shown when user presses Escape
	fmt.print(forge.step_wrap_cancelled(cancel_chrome))

	// Close the wizard sequence
	fmt.print(forge.wizard_end())
}
