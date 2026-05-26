package forge

import "core:strings"
import "core:testing"
import style "../style"

@(test)
test_step_wrap_active_header :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_active(chrome, "my-app")
	expected_header := style.CYAN + "◇" + style.RESET + "  Project name?\r\n"
	testing.expect(t, strings.contains(result, expected_header), "should contain active header")
}

@(test)
test_step_wrap_active_pipe_prefix :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_active(chrome, "my-app")
	expected_line := style.CYAN + "│" + style.RESET + "  my-app\r\n"
	testing.expect(t, strings.contains(result, expected_line), "should prefix prompt lines with │")
}

@(test)
test_step_wrap_active_trailing_connector :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_active(chrome, "my-app")
	expected_trail := style.CYAN + "│" + style.RESET + "\r\n"
	testing.expect(t, strings.contains(result, expected_trail), "should have trailing connector")
}

@(test)
test_step_wrap_active_skips_empty_lines :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Pick?"}
	// Two non-empty lines — trailing connector is the only bare │
	result := step_wrap_active(chrome, "line one\nline two")
	// Count occurrences of │  (pipe + two spaces) = prompt lines only
	count := strings.count(result, style.CYAN+"│"+style.RESET+"  ")
	testing.expect_value(t, count, 2)
}

@(test)
test_step_wrap_done_header :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_done(chrome, "my-app")
	expected_header := style.CYAN + "◆" + style.RESET + "  Project name?\r\n"
	testing.expect(t, strings.contains(result, expected_header), "should contain done header")
}

@(test)
test_step_wrap_done_answer_dim :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_done(chrome, "my-app")
	testing.expect(t, strings.contains(result, style.DIM+"my-app"+style.RESET), "answer should be dim")
}

@(test)
test_step_wrap_error_red_glyph :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_error(chrome, "invalid name")
	testing.expect(t, strings.contains(result, style.RED+"◆"+style.RESET), "error glyph should be red")
}

@(test)
test_step_wrap_error_contains_message :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_error(chrome, "invalid name")
	testing.expect(t, strings.contains(result, "invalid name"), "should contain error message")
}

@(test)
test_step_wrap_cancelled_dim_glyph :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_cancelled(chrome)
	testing.expect(t, strings.contains(result, style.DIM+"◆"+style.RESET), "cancelled glyph should be dim")
}

@(test)
test_step_wrap_cancelled_text :: proc(t: ^testing.T) {
	chrome := StepChrome{label = "Project name?"}
	result := step_wrap_cancelled(chrome)
	testing.expect(t, strings.contains(result, "(cancelled)"), "should contain cancelled text")
}

@(test)
test_wizard_end_contains_empty_diamond :: proc(t: ^testing.T) {
	result := wizard_end()
	testing.expect(t, strings.contains(result, "◇"), "wizard_end should contain ◇")
}

@(test)
test_wizard_end_ends_with_blank_line :: proc(t: ^testing.T) {
	result := wizard_end()
	testing.expect(t, strings.has_suffix(result, "\r\n\r\n"), "wizard_end should end with blank line")
}
