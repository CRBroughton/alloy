package main

import forge "../../../src/forge"

SetupCtx :: struct {
	project_name: string,
	install_deps: bool,
}

main :: proc() {
	name_result := forge.run_text_prompt("Nuxt application", "my-nuxt-app")
	if name_result.status == .Cancelled do return

	install_result := forge.run_confirm_prompt("Install dependencies?")
	if install_result.status == .Cancelled do return

	ctx := SetupCtx {
		project_name = name_result.value,
		install_deps = install_result.value == "Yes",
	}

	tasks := []forge.Task(SetupCtx){{label = "Create Directory", run = proc(c: ^SetupCtx) -> bool {
				result := forge.exec({"pnpm", "init"})
				return result.success
			}}}

	setup_result := forge.run_task_step(
		label = "Setting up project",
		ctx = &ctx,
		stop_on_error = true,
		tasks = tasks,
	)
	if setup_result.status == .Error do return

	forge.wizard_end()
}
