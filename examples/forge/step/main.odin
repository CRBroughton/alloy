package main

import forge "../../../src/forge"
import "core:fmt"
import "core:time"

// SetupCtx carries wizard answers into task run procs.
// Odin proc literals are not closures; pass captured values via Task.data.
SetupCtx :: struct {
	project_name: string,
	framework:    string,
	install_deps: bool,
}

main :: proc() {
	name_result := forge.run_text_prompt(
		"Project name?",
		"my-app",
		proc(v: string) -> string {
			if len(v) == 0 do return "Project name cannot be empty"
			return ""
		},
	)
	if name_result.status == .Cancelled do return

	framework_result := forge.run_select_prompt(
		"Framework?",
		[]forge.SelectOption {
			{label = "React", value = "react"},
			{label = "Vue", value = "vue"},
			{label = "Svelte", value = "svelte"},
		},
	)
	if framework_result.status == .Cancelled do return

	install_result := forge.run_confirm_prompt("Install dependencies?")
	if install_result.status == .Cancelled do return

	ctx := SetupCtx {
		project_name = name_result.value,
		framework    = framework_result.value,
		install_deps = install_result.value == "Yes",
	}

	tasks := []forge.Task(SetupCtx){{label = "Create directory", run = proc(c: ^SetupCtx) -> bool {
				time.sleep(3000 * time.Millisecond)
				return true
			}}, {label = "Copy template files", run = proc(c: ^SetupCtx) -> bool {
				time.sleep(2000 * time.Millisecond)
				return false
			}}, {label = "Init git repository", run = proc(c: ^SetupCtx) -> bool {
				if !c.install_deps do return true
				time.sleep(1000 * time.Millisecond)
				return true
			}}}
	setup_result := forge.run_task_step(
		label = "Setting up project",
		ctx = &ctx,
		stop_on_error = true,
		tasks = tasks,
	)

	if setup_result.status == .Error do return

	forge.wizard_end()

	fmt.printf("Created %s with %s.\n", ctx.project_name, ctx.framework)
}
