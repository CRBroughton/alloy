package forge

import style "../style"
import "core:fmt"
import "core:strings"
import "core:sync"
import "core:thread"
import "core:time"

TaskStatus :: enum {
	Pending,
	Running,
	Done,
	Failed,
}

// Task is a single unit of work executed by run_tasks or run_task_step.
//
// T is the shared context type passed to every task in the list.
// The `run` proc receives a typed ^T pointer — no cast needed at the call site.
// Return true on success, false to mark the task as Failed.
//
// Example:
// ```odin
// SetupCtx :: struct { name: string }
// ctx := SetupCtx{name = "my-app"}
//
// tasks := []forge.Task(SetupCtx){
//     {
//         label = "Create directory",
//         run   = proc(c: ^SetupCtx) -> bool {
//             return os.make_directory(c.name) == nil
//         },
//     },
// }
// ```
Task :: struct($T: typeid) {
	label: string,
	run:   proc(^T) -> bool,
}

// TaskState is the runtime status of a single task inside the render loop.
// Created internally by run_tasks; not constructed directly by callers.
TaskState :: struct {
	label:  string,
	status: TaskStatus,
}

spinner_frames := []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}

// task_status_icon returns the ANSI-styled glyph for a task's current status.
// `frame_index` selects the spinner frame for Running tasks; ignored otherwise.
//
// Example:
// ```odin
// icon := task_status_icon(TaskState{label = "Install", status = .Done}, 0)
// // → "\x1b[32m✔\x1b[0m"
// ```
task_status_icon :: proc(ts: TaskState, frame_index: int) -> string {
	switch ts.status {
	case .Pending:
		return fmt.tprintf("%s○%s", style.DIM, style.RESET)
	case .Running:
		frame := spinner_frames[frame_index % len(spinner_frames)]
		return fmt.tprintf("%s%s%s", style.CYAN, frame, style.RESET)
	case .Done:
		return fmt.tprintf("%s✔%s", style.GREEN, style.RESET)
	case .Failed:
		return fmt.tprintf("%s✖%s", style.RED, style.RESET)
	}
	return "?"
}

// task_runner_view renders the full task list as a single string.
// Each task occupies one │-prefixed line. `frame_index` drives spinner
// animation for any Running tasks; advance it ~80 ms apart in the render loop.
//
// Example:
// ```odin
// states := []TaskState{
//     {label = "Create directory", status = .Done},
//     {label = "Install deps",     status = .Running},
// }
// fmt.print(task_runner_view(states, 3))
// // │  ✔  Create directory
// // │  ⠸  Install deps
// ```
task_runner_view :: proc(task_states: []TaskState, frame_index: int) -> string {
	buf: [dynamic]byte
	defer delete(buf)
	for ts in task_states {
		icon := task_status_icon(ts, frame_index)
		line := fmt.tprintf("%s│%s  %s  %s\r\n", style.CYAN, style.RESET, icon, ts.label)
		for b in transmute([]byte)line {append(&buf, b)}
	}
	return fmt.tprintf("%s", string(buf[:]))
}

// run_tasks executes tasks sequentially with a live spinner for each.
// Each task runs on its own thread; the main thread drives the render loop at
// ~80 ms per frame. Returns the final rendered view and true if every task
// returned true.
//
// When `stop_on_error` is true (default), the first failed task halts the
// sequence — remaining tasks are left as Pending and not started.
//
// Prefer run_task_step for wizard use — it adds Step chrome and integrates
// with wizard_end output.
//
// Example:
// ```odin
// _, ok := run_tasks(&ctx, tasks = []Task(SetupCtx){
//     {label = "Build",  run = proc(c: ^SetupCtx) -> bool { return build(c.name)  }},
//     {label = "Deploy", run = proc(c: ^SetupCtx) -> bool { return deploy(c.name) }},
// })
// ```
run_tasks :: proc(ctx: ^$T, stop_on_error: bool = true, tasks: []Task(T)) -> (string, bool) {
	task_states := make([]TaskState, len(tasks))
	defer delete(task_states)
	for task, i in tasks {
		task_states[i] = TaskState {
			label  = task.label,
			status = .Pending,
		}
	}

	old_termios := raw_mode_enter()
	defer raw_mode_exit(old_termios)

	frame_index := 0
	last_lines := 0
	all_ok := true

	for task_index in 0 ..< len(tasks) {
		task_states[task_index].status = .Running

		Result :: struct {
			done: bool,
			ok:   bool,
		}
		result := Result{}
		mu: sync.Mutex

		// _TaskRun is specialised at compile time for each T because it lives
		// inside this polymorphic proc body.  The thread proc literal can
		// reference _TaskRun as a type (compile-time) without capturing it.
		_TaskRun :: struct {
			task_run: proc(^T) -> bool,
			ctx:      ^T,
			done:     ^bool,
			ok:       ^bool,
			mu:       ^sync.Mutex,
		}
		run_data := new(_TaskRun)
		run_data^ = _TaskRun{
			task_run = tasks[task_index].run,
			ctx      = ctx,
			done     = &result.done,
			ok       = &result.ok,
			mu       = &mu,
		}

		t := thread.create_and_start_with_data(run_data, proc(data: rawptr) {
			d := cast(^_TaskRun)data
			ok := d.task_run(d.ctx)
			sync.mutex_lock(d.mu)
			d.ok^   = ok
			d.done^ = true
			sync.mutex_unlock(d.mu)
			free(d)
		})

		for {
			sync.mutex_lock(&mu)
			done := result.done
			sync.mutex_unlock(&mu)
			if done do break

			rendered := task_runner_view(task_states, frame_index)
			cursor_up(last_lines)
			render_inline(rendered)
			last_lines = count_lines(rendered)
			frame_index += 1
			time.sleep(80 * time.Millisecond)
		}

		thread.join(t)
		thread.destroy(t)

		if result.ok {
			task_states[task_index].status = .Done
		} else {
			task_states[task_index].status = .Failed
			all_ok = false
			if stop_on_error do break
		}
	}

	final := task_runner_view(task_states, 0)
	cursor_up(last_lines)
	render_locked(final)

	return final, all_ok
}

// run_task_step prints a ◆ header, runs tasks sequentially, and returns a
// StepResult compatible with the wizard flow. Output is accumulated so
// wizard_end can print the full summary to the main screen on exit.
//
// Set `stop_on_error = false` to run all tasks regardless of failures.
//
// Example:
// ```odin
// result := forge.run_task_step("Setting up project", &ctx, tasks = []forge.Task(SetupCtx){
//     {
//         label = "Create directory",
//         run   = proc(c: ^SetupCtx) -> bool {
//             return os.make_directory(c.name) == nil
//         },
//     },
//     {
//         label = "Init git repository",
//         run   = proc(c: ^SetupCtx) -> bool {
//             if !c.install_deps do return true
//             res := forge.exec({"git", "init", c.name})
//             return res.exit_code == 0
//         },
//     },
// })
// if result.status == .Error do return
// ```
run_task_step :: proc(label: string, ctx: ^$T, stop_on_error: bool = true, tasks: []Task(T)) -> StepResult {
	header := fmt.tprintf("%s◆%s  %s\r\n", style.CYAN, style.RESET, label)
	fmt.printf("%s", header)
	strings.write_string(&_forge_locked, header)

	final_view, success := run_tasks(ctx, stop_on_error, tasks)
	strings.write_string(&_forge_locked, final_view)

	status := StepStatus.Done if success else .Error
	return StepResult{status = status}
}
