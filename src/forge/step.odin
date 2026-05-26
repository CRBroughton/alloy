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

// wizard_end renders the closing ◇ line that ends a forge wizard.
wizard_end :: proc() -> string {
	return fmt.tprintf("%s◇%s\r\n\r\n", style.CYAN, style.RESET)
}
