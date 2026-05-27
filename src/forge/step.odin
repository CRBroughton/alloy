package forge

import style "../style"
import "core:fmt"
import "core:strings"

StepChrome :: struct {
	label:  string,
	status: StepStatus,
}

// step_wrap_active wraps prompt_view output with active chrome (◇).
// Call this each frame while the step is running.
step_wrap_active :: proc(chrome: StepChrome, prompt_view: string) -> string {
	buf: strings.Builder
	strings.builder_init(&buf)
	defer strings.builder_destroy(&buf)

	fmt.sbprintf(&buf, "%s◇%s  %s\r\n", style.CYAN, style.RESET, chrome.label)

	lines := strings.split_lines(prompt_view)
	defer delete(lines)
	for line in lines {
		if len(line) == 0 do continue
		fmt.sbprintf(&buf, "%s│%s  %s\r\n", style.CYAN, style.RESET, line)
	}

	fmt.sbprintf(&buf, "%s│%s\r\n", style.CYAN, style.RESET)

	return fmt.tprintf("%s", strings.to_string(buf))
}

// step_wrap_done wraps the final answer with locked chrome (◆).
// Call this once when the step completes — output is permanent.
step_wrap_done :: proc(chrome: StepChrome, answer: string) -> string {
	buf: strings.Builder
	strings.builder_init(&buf)
	defer strings.builder_destroy(&buf)

	fmt.sbprintf(&buf, "%s◆%s  %s\r\n", style.CYAN, style.RESET, chrome.label)
	fmt.sbprintf(
		&buf,
		"%s│%s  %s%s%s\r\n",
		style.CYAN,
		style.RESET,
		style.DIM,
		answer,
		style.RESET,
	)

	return fmt.tprintf("%s", strings.to_string(buf))
}

// step_wrap_error wraps an error message with red chrome.
step_wrap_error :: proc(chrome: StepChrome, message: string) -> string {
	return fmt.tprintf(
		"%s◆%s  %s\r\n%s│%s  %s%s%s\r\n",
		style.RED,
		style.RESET,
		chrome.label,
		style.RED,
		style.RESET,
		style.DIM,
		message,
		style.RESET,
	)
}

// step_wrap_cancelled renders a dimmed cancelled step.
step_wrap_cancelled :: proc(chrome: StepChrome) -> string {
	return fmt.tprintf(
		"%s◆%s  %s%s (cancelled)%s\r\n",
		style.DIM,
		style.RESET,
		chrome.label,
		style.DIM,
		style.RESET,
	)
}

wizard_end_view :: proc() -> string {
	return fmt.tprintf("%s◇%s\r\n\r\n", style.CYAN, style.RESET)
}

// wizard_end prints the closing ◇ line, exits the alternate screen, and
// prints all accumulated locked step output to the main screen.
// Cleans up internal state so the wizard can be re-entered if needed.
wizard_end :: proc() {
	end_view := wizard_end_view()
	fmt.printf("%s", end_view)
	strings.write_string(&_forge_locked, end_view)
	// Exit alt screen → main screen restored; then print wizard summary inline.
	fmt.printf("\x1b[?1049l\x1b[?25h")
	fmt.printf("%s", strings.to_string(_forge_locked))
	strings.builder_destroy(&_forge_locked)
	_forge_started = false
}
