package main

import forge "../../../src/forge"
import "core:fmt"
import "core:strings"
import "core:time"

// SetupCtx carries wizard answers into task run procs.
// Odin proc literals are not closures; pass captured values via the typed ctx pointer.
SetupCtx :: struct {
	project_name: string,
	extras:       []string,
	install_deps: bool,
}

main :: proc() {
	name_result := forge.run_text_prompt("Project name?", "my-app")
	if name_result.status == .Cancelled do return

	extras_result := forge.run_multi_select_prompt(
		"Extras?",
		[]forge.MultiSelectOption{
			{
				label       = "ESLint",
				value       = "eslint",
				description = "Fast linting for JavaScript",
				default     = true,
			},
			{
				label       = "Prettier",
				value       = "prettier",
				description = "An opinionated code formatter",
			},
			{
				label       = "Husky",
				value       = "husky",
				description = "Git hooks made easy",
			},
			{
				label       = "Testing Library",
				value       = "testing-library",
				description = "Simple and complete testing utilities",
			},
		},
	)
	if extras_result.status == .Cancelled do return
	defer delete(extras_result.values)

	install_result := forge.run_confirm_prompt("Install dependencies?")
	if install_result.status == .Cancelled do return

	ctx := SetupCtx{
		project_name = name_result.value,
		extras       = extras_result.values,
		install_deps = install_result.value == "Yes",
	}

	tasks := []forge.Task(SetupCtx){
		{
			label = "Create directory",
			run   = proc(c: ^SetupCtx) -> bool {
				time.sleep(1000 * time.Millisecond)
				return true
			},
		},
		{
			label = "Copy template files",
			run   = proc(c: ^SetupCtx) -> bool {
				time.sleep(1500 * time.Millisecond)
				return true
			},
		},
		{
			label = "Install extras",
			run   = proc(c: ^SetupCtx) -> bool {
				if len(c.extras) == 0 do return true
				time.sleep(2000 * time.Millisecond)
				return true
			},
		},
	}
	setup_result := forge.run_task_step(
		label         = "Setting up project",
		ctx           = &ctx,
		stop_on_error = true,
		tasks         = tasks,
	)

	if setup_result.status == .Error do return

	forge.wizard_end()

	if len(ctx.extras) > 0 {
		extras := strings.join(ctx.extras, ", ")
		defer delete(extras)
		fmt.printf("Created %s with extras: %s.\n", ctx.project_name, extras)
	} else {
		fmt.printf("Created %s.\n", ctx.project_name)
	}
}
