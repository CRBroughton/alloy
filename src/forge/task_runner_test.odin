package forge

import "core:strings"
import "core:testing"
import style "../style"

@(test)
test_task_status_icon_pending :: proc(t: ^testing.T) {
	ts := TaskState{label = "Create directory", status = .Pending}
	result := task_status_icon(ts, 0)
	testing.expect(t, strings.contains(result, "○"), "pending icon should be ○")
	testing.expect(t, strings.contains(result, style.DIM), "pending icon should be dim")
}

@(test)
test_task_status_icon_running :: proc(t: ^testing.T) {
	ts := TaskState{label = "Install", status = .Running}
	result := task_status_icon(ts, 0)
	testing.expect(t, strings.contains(result, style.CYAN), "running icon should be cyan")
	// frame 0 is ⠋
	testing.expect(t, strings.contains(result, "⠋"), "running icon should show spinner frame 0")
}

@(test)
test_task_status_icon_running_cycles_frames :: proc(t: ^testing.T) {
	ts := TaskState{label = "Install", status = .Running}
	// frame index 1 → ⠙
	result := task_status_icon(ts, 1)
	testing.expect(t, strings.contains(result, "⠙"), "frame 1 should be ⠙")
}

@(test)
test_task_status_icon_done :: proc(t: ^testing.T) {
	ts := TaskState{label = "Create directory", status = .Done}
	result := task_status_icon(ts, 0)
	testing.expect(t, strings.contains(result, "✔"), "done icon should be ✔")
	testing.expect(t, strings.contains(result, style.GREEN), "done icon should be green")
}

@(test)
test_task_status_icon_failed :: proc(t: ^testing.T) {
	ts := TaskState{label = "Create directory", status = .Failed}
	result := task_status_icon(ts, 0)
	testing.expect(t, strings.contains(result, "✖"), "failed icon should be ✖")
	testing.expect(t, strings.contains(result, style.RED), "failed icon should be red")
}

@(test)
test_task_runner_view_contains_labels :: proc(t: ^testing.T) {
	states := []TaskState{
		{label = "Create directory", status = .Pending},
		{label = "Copy templates",   status = .Done},
	}
	result := task_runner_view(states, 0)
	testing.expect(t, strings.contains(result, "Create directory"), "should contain first label")
	testing.expect(t, strings.contains(result, "Copy templates"),   "should contain second label")
}

@(test)
test_task_runner_view_pipe_prefix :: proc(t: ^testing.T) {
	states := []TaskState{{label = "Install", status = .Pending}}
	result := task_runner_view(states, 0)
	expected := style.CYAN + "│" + style.RESET
	testing.expect(t, strings.contains(result, expected), "each line should have │ prefix")
}

@(test)
test_task_runner_view_crlf_line_endings :: proc(t: ^testing.T) {
	states := []TaskState{{label = "Install", status = .Pending}}
	result := task_runner_view(states, 0)
	testing.expect(t, strings.contains(result, "\r\n"), "lines should end with \\r\\n")
}

@(test)
test_task_runner_view_one_line_per_task :: proc(t: ^testing.T) {
	states := []TaskState{
		{label = "A", status = .Pending},
		{label = "B", status = .Pending},
		{label = "C", status = .Done},
	}
	result := task_runner_view(states, 0)
	testing.expect_value(t, count_lines(result), 3)
}
