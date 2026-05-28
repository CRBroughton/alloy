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

// GridCell wraps a rendered string with layout metadata.
// Mirrors CSS grid-column: span N and grid-row: span N.
GridCell :: struct {
	content:     string,
	column_span: int, // default 1 — how many columns this cell occupies
	row_span:    int, // default 1 — reserved; row span is not yet implemented
}

// cell is the primary constructor. column_span and row_span default to 1.
cell :: proc(content: string, column_span: int = 1, row_span: int = 1) -> GridCell {
	return GridCell{content = content, column_span = column_span, row_span = row_span}
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

// repeat returns a slice of count copies of track.
// Mirrors CSS repeat() — e.g. repeat(3, fr(1)) gives three equal columns.
// The caller owns the returned slice.
repeat :: proc(count: int, track: Track) -> []Track {
	tracks := make([]Track, count)
	for i in 0 ..< count {
		tracks[i] = track
	}
	return tracks
}

// grid_gap sets column_gap on g. Mirrors the CSS gap shorthand.
grid_gap :: proc(g: ^Grid, gap: int) {
	g.column_gap = gap
}

// Breakpoint applies a column layout when g.width <= max_width.
// List narrowest first — same convention as CSS max-width media queries.
Breakpoint :: struct {
	max_width: int,
	columns:   []Track,
}

// grid_breakpoint applies the first matching breakpoint to g.template_columns.
// If no breakpoint matches, template_columns is unchanged.
grid_breakpoint :: proc(g: ^Grid, breakpoints: []Breakpoint) {
	for bp in breakpoints {
		if g.width <= bp.max_width {
			g.template_columns = bp.columns
			return
		}
	}
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

// grid_cell_width returns the character width of a cell spanning span_count
// columns starting at col_index, including the interior gaps.
@(private)
grid_cell_width :: proc(widths: []int, col_index, span_count, gap: int) -> int {
	total := 0
	for i in col_index ..< col_index + span_count {
		if i < len(widths) {
			total += widths[i]
		}
	}
	// Interior gaps only — gaps between spanned columns, not around the cell
	total += gap * max(span_count - 1, 0)
	return total
}

// grid_view lays GridCells out according to template_columns.
// Cells wrap to the next row when they exceed the column count.
// Use cell() to construct GridCell values.
grid_view :: proc(g: Grid, cells: ..GridCell) -> string {
	n := len(g.template_columns)
	widths := grid_resolve_column_widths(g)
	defer delete(widths)

	gap_str := strings.repeat(" ", g.column_gap)
	defer delete(gap_str)

	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	// Group cells into rows based on column_span
	rows: [dynamic][]GridCell
	defer {
		for row in rows {
			delete(row)
		}
		delete(rows)
	}

	current_row: [dynamic]GridCell
	col := 0
	for c in cells {
		span := max(c.column_span, 1)
		if col + span > n {
			if len(current_row) > 0 {
				append(&rows, current_row[:])
				current_row = make([dynamic]GridCell)
			}
			col = 0
		}
		append(&current_row, c)
		col += span
	}
	if len(current_row) > 0 {
		append(&rows, current_row[:])
	}

	// Render each row
	for row in rows {
		// Record each cell's starting column index
		col_starts := make([]int, len(row))
		defer delete(col_starts)
		col_cursor := 0
		for c, i in row {
			col_starts[i] = col_cursor
			col_cursor += max(c.column_span, 1)
		}

		// Split all cells into lines
		all_lines := make([][]string, len(row))
		defer {
			for lines in all_lines {
				delete(lines)
			}
			delete(all_lines)
		}
		max_lines := 0
		for c, i in row {
			all_lines[i] = strings.split(c.content, "\r\n")
			if len(all_lines[i]) > max_lines do max_lines = len(all_lines[i])
		}

		// Render line by line
		for line_idx in 0 ..< max_lines {
			for c, i in row {
				span := max(c.column_span, 1)
				c_width := grid_cell_width(widths, col_starts[i], span, g.column_gap)

				line := ""
				if line_idx < len(all_lines[i]) {
					line = all_lines[i][line_idx]
				}

				if visible_len(line) > c_width {
					line = truncate(line, c_width)
				}
				buffer_write(&buf, pad_right_visible(line, c_width))

				if i < len(row) - 1 {
					buffer_write(&buf, gap_str)
				}
			}
			buffer_write(&buf, "\r\n")
		}
	}

	return fmt.tprintf("%s", buffer_string(&buf))
}
