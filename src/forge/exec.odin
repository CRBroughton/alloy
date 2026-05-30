package forge

import "core:os"
import "core:strings"

ExecResult :: struct {
	exit_code: int,
	success:   bool,
	stdout:    string,
	stderr:    string,
}

// exec runs command, captures stdout and stderr, and returns the result.
// Use inside task run procs — output is captured so the spinner is not corrupted.
//
// Example:
// ```odin
// res := forge.exec({"git", "init", project_name})
// return res.success
// ```
exec :: proc(command: []string, working_dir: string = "") -> ExecResult {
	state, stdout_types, stderr_bytes, _ := os.process_exec(
		os.Process_Desc{command = command, working_dir = working_dir},
		context.allocator,
	)
	return ExecResult {
		exit_code = state.exit_code,
		success = state.success,
		stdout = strings.clone_from_bytes(stdout_types),
		stderr = strings.clone_from_bytes(stderr_bytes),
	}
}
