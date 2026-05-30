package main

import forge "../../../src/forge"
import "core:fmt"
import "core:os"

SetupCtx :: struct {
	project_name: string,
	install_deps: bool,
	init_git:     bool,
}

main :: proc() {
	name_result := forge.run_text_prompt("Project name", "my-nuxt-app")
	if name_result.status == .Cancelled do return

	install_result := forge.run_confirm_prompt("Install dependencies?")
	if install_result.status == .Cancelled do return

	git_result := forge.run_confirm_prompt("Initialise git?")
	if git_result.status == .Cancelled do return

	ctx := SetupCtx {
		project_name = name_result.value,
		install_deps = install_result.value == "Yes",
		init_git     = git_result.value == "Yes",
	}

	always_tasks := []forge.Task(SetupCtx) {
		{label = "Scaffold project", run = proc(c: ^SetupCtx) -> bool {
				result := forge.exec(
					{
						"pnpm",
						"dlx",
						"giget@latest",
						"gh:nuxt/starter#v4",
						c.project_name,
						"--force",
					},
				)
				defer forge.exec_result_destroy(&result)
				return result.success
			}},
		{
			label = "Configure TypeScript",
			run = proc(c: ^SetupCtx) -> bool {
				dest := fmt.tprintf("%s/nuxt.config.ts", c.project_name)
				err := os.copy_file(dest, "templates/nuxt.config.ts")
				return err == nil
			},
		},
	}

	optional_tasks: [dynamic]forge.Task(SetupCtx)
	defer delete(optional_tasks)

	if ctx.install_deps {
		append(&optional_tasks, forge.Task(SetupCtx) {
			label = "Install dependencies",
			run = proc(c: ^SetupCtx) -> bool {
				result := forge.exec({"pnpm", "install"}, c.project_name)
				defer forge.exec_result_destroy(&result)
				return result.success
			},
		})
	}

	if ctx.init_git {
		append(&optional_tasks, forge.Task(SetupCtx) {
			label = "Initialise git",
			run = proc(c: ^SetupCtx) -> bool {
				result := forge.exec({"git", "init"}, c.project_name)
				defer forge.exec_result_destroy(&result)
				return result.success
			},
		})
	}

	tasks_buf: [dynamic]forge.Task(SetupCtx)
	defer delete(tasks_buf)
	append(&tasks_buf, ..always_tasks)
	append(&tasks_buf, ..optional_tasks[:])

	setup_result := forge.run_task_step(
		label = "Setting up Nuxt project",
		ctx = &ctx,
		stop_on_error = true,
		tasks = tasks_buf[:],
	)
	if setup_result.status == .Error do return

	forge.wizard_end()
}
