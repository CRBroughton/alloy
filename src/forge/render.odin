package forge

import "core:fmt"
cursor_up :: proc(line_count: int) {
	if line_count <= 0 do return
	fmt.printf("\x1b[%dA", line_count)
	fmt.printf("\x1b[J")
}

count_lines :: proc(s: string) -> int {
	if len(s) == 0 do return 0
	count := 1

	for index := 0; index < len(s); index += 1 {
		if s[index] == '\n' do count += 1
	}

	return count
}

render_inline :: proc(s: string) {
	fmt.print(s)
}

render_locked :: proc(s: string) {
	fmt.print(s)
}
