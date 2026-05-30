package forge

import "core:testing"

@(test)
test_exec_success :: proc(t: ^testing.T) {
	result := exec({"echo", "hello"})
	testing.expect(t, result.success, "echo should succeed")
	testing.expect_value(t, result.exit_code, 0)
}

@(test)
test_exec_captures_stdout :: proc(t: ^testing.T) {
	result := exec({"echo", "hello"})
	testing.expect_value(t, result.stdout, "hello\n")
}

@(test)
test_exec_failure :: proc(t: ^testing.T) {
	result := exec({"false"})
	testing.expect(t, !result.success, "false should not succeed")
	testing.expect(t, result.exit_code != 0, "exit code should be non-zero")
}

@(test)
test_exec_captures_stderr :: proc(t: ^testing.T) {
	result := exec({"sh", "-c", "echo error >&2"})
	testing.expect_value(t, result.stderr, "error\n")
}

@(test)
test_exec_working_dir :: proc(t: ^testing.T) {
	result := exec({"pwd"}, "/tmp")
	testing.expect_value(t, result.stdout, "/tmp\n")
}

@(test)
test_exec_invalid_command :: proc(t: ^testing.T) {
	result := exec({"__nonexistent_cmd_12345__"})
	testing.expect(t, !result.success, "nonexistent command should fail")
}