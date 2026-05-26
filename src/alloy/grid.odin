package alloy

import "core:fmt"
import "core:strings"

Fr :: struct {
	value: int,
}

Fixed :: struct {
	cols: int,
}

Track :: union {
	Fr,
	Fixed,
}

fr :: proc(value: int) -> Track {
	return Fr{value}
}

fixed :: proc(cols: int) -> Track {
	return Fixed{cols}
}


Grid :: struct {
	template_columns: []Track,
	column_gap:       int,
	width:            int,
}

grid_init :: proc(grid: ^Grid, width: int) {
	grid.width = width
	grid.column_gap = 0
}

grid_resolve_column_widths :: proc(grid: Grid) -> []int {
	n := len(grid.template_columns)
	widths := make([]int, n)

	gaps := grid.column_gap * max(n - 1, 0)
	available := grid.width - gaps

	total_fixed := 0
	total_fr := 0
	for track in grid.template_columns {
		switch t in track {
		case Fixed:
			total_fixed += t.cols
		case Fr:
			total_fr += t.value
		}
	}

	remaining := available - total_fixed

	for track, i in grid.template_columns {
		switch t in track {
		case Fixed:
			widths[i] = t.cols
		case Fr:
			if total_fr > 0 {
				widths[i] = (t.value * remaining) / total_fr
			}
		}
	}

	return widths
}

// pad_right pads s to width characters with trailing spaces.
// Measures by byte length — see note on ANSI codes below.
@(private)
pad_right :: proc(s: string, width: int) -> string {
	n := len(s)
	if n >= width do return s
	padding := strings.repeat(" ", width - n)
	defer delete(padding)
	return fmt.tprintf("%s%s", s, padding)
}

grid_view :: proc(grid: Grid, cells: ..string) -> string {
	n := len(grid.template_columns)
	widths := grid_resolve_column_widths(grid)
	defer delete(widths)

	col_lines := make([][]string, n)
	defer {
		for lines in col_lines {
			delete(lines)
		}
		delete(col_lines)
	}

	for i in 0 ..< n {
		content := i < len(cells) ? cells[i] : ""
		col_lines[i] = strings.split(content, "\r\n")
	}

	max_rows := 0
	for lines in col_lines {
		if len(lines) > max_rows do max_rows = len(lines)
	}

	gap := strings.repeat(" ", grid.column_gap)
	defer delete(gap)

	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	for row in 0 ..< max_rows {
		for col in 0 ..< n {
			line := ""
			if row < len(col_lines[col]) {
				line = col_lines[col][row]
			}
			buffer_write(&buf, pad_right(line, widths[col]))
			if col < n - 1 {
				buffer_write(&buf, gap)
			}
		}
		buffer_write(&buf, "\r\n")
	}

	return fmt.tprintf("%s", buffer_string(&buf))
}
