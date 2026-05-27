package main
import forge "../../../src/forge"
import "core:fmt"

main :: proc() {
	name_result := forge.run_text_prompt("Project name?", "my-app")
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

	forge.wizard_end()

	fmt.printf("Creating %s with %s...\n", name_result.value, framework_result.value)
}
