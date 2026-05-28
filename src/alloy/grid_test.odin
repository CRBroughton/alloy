package alloy

import "core:testing"

@(test)
test_grid_resolve_equal_fr :: proc(t: ^testing.T) {
	grid: Grid
	grid_init(&grid, 80)
	grid.template_columns = {fr(1), fr(1)}
	grid.column_gap = 0

	widths := grid_resolve_column_widths(grid)
	defer delete(widths)

	testing.expect_value(t, widths[0], 40)
	testing.expect_value(t, widths[1], 40)
}

@(test)
test_grid_resolve_fr_with_gap :: proc(t: ^testing.T) {
	grid: Grid
	grid_init(&grid, 80)
	grid.template_columns = {fr(1), fr(1)}
	grid.column_gap = 2

	widths := grid_resolve_column_widths(grid)
	defer delete(widths)

	// 80 - 2 (one gap) = 78, split equally = 39 each
	testing.expect_value(t, widths[0], 39)
	testing.expect_value(t, widths[1], 39)
}

@(test)
test_grid_resolve_mixed_tracks :: proc(t: ^testing.T) {
	grid: Grid
	grid_init(&grid, 80)
	grid.template_columns = {fixed(20), fr(1)}
	grid.column_gap = 0

	widths := grid_resolve_column_widths(grid)
	defer delete(widths)

	testing.expect_value(t, widths[0], 20)
	testing.expect_value(t, widths[1], 60)
}

// --- repeat / grid_gap ---

@(test)
test_repeat_count :: proc(t: ^testing.T) {
	tracks := repeat(3, fr(1))
	defer delete(tracks)
	testing.expect_value(t, len(tracks), 3)
}

@(test)
test_repeat_fills_correct_track :: proc(t: ^testing.T) {
	tracks := repeat(2, fixed(20))
	defer delete(tracks)

	for track in tracks {
		f, ok := track.(Fixed)
		testing.expect(t, ok, "each track should be Fixed")
		testing.expect_value(t, f.cols, 20)
	}
}

@(test)
test_grid_gap_sets_column_gap :: proc(t: ^testing.T) {
	g: Grid
	grid_init(&g, 80)
	grid_gap(&g, 4)
	testing.expect_value(t, g.column_gap, 4)
}

@(test)
test_repeat_with_grid_resolves_widths :: proc(t: ^testing.T) {
	g: Grid
	grid_init(&g, 90)
	g.template_columns = repeat(3, fr(1))
	defer delete(g.template_columns)
	grid_gap(&g, 0)

	widths := grid_resolve_column_widths(g)
	defer delete(widths)

	testing.expect_value(t, widths[0], 30)
	testing.expect_value(t, widths[1], 30)
	testing.expect_value(t, widths[2], 30)
}

// --- GridCell / cell() ---

@(test)
test_cell_defaults :: proc(t: ^testing.T) {
	c := cell("hello")
	testing.expect_value(t, c.column_span, 1)
	testing.expect_value(t, c.row_span, 1)
	testing.expect_value(t, c.content, "hello")
}

@(test)
test_cell_custom_span :: proc(t: ^testing.T) {
	c := cell("header", column_span = 3)
	testing.expect_value(t, c.column_span, 3)
}

// --- grid_cell_width ---

@(test)
test_grid_cell_width_single :: proc(t: ^testing.T) {
	widths := []int{20, 30, 40}
	w := grid_cell_width(widths, 0, 1, 2)
	testing.expect_value(t, w, 20)
}

@(test)
test_grid_cell_width_span_two :: proc(t: ^testing.T) {
	widths := []int{20, 30, 40}
	// span 2 starting at col 0: 20 + 30 + 1 interior gap
	w := grid_cell_width(widths, 0, 2, 1)
	testing.expect_value(t, w, 51)
}

@(test)
test_grid_cell_width_span_all :: proc(t: ^testing.T) {
	widths := []int{20, 20, 20}
	// span 3, gap 2: 20+20+20 + 2 interior gaps = 64
	w := grid_cell_width(widths, 0, 3, 2)
	testing.expect_value(t, w, 64)
}

// --- grid_view ---

@(test)
test_grid_view_two_columns :: proc(t: ^testing.T) {
	grid: Grid
	grid_init(&grid, 10)
	grid.template_columns = {fr(1), fr(1)}
	grid.column_gap = 0

	result := grid_view(grid, cell("AB"), cell("CD"))
	testing.expect(t, len(result) > 0, "grid_view should return a non-empty string")
}

@(test)
test_grid_view_span_fills_width :: proc(t: ^testing.T) {
	g: Grid
	grid_init(&g, 30)
	g.template_columns = repeat(3, fr(1))
	defer delete(g.template_columns)

	// Header spans all 3 columns — should occupy the full 30 chars
	result := grid_view(g, cell("Header", column_span = 3))
	testing.expect(t, len(result) > 0, "spanned cell should render")
}

// --- Breakpoints ---

@(test)
test_grid_breakpoint_narrow :: proc(t: ^testing.T) {
	g: Grid
	grid_init(&g, 60)

	narrow := []Track{fr(1)}
	wide := []Track{fr(1), fr(3)}

	grid_breakpoint(&g, []Breakpoint{{max_width = 80, columns = narrow}, {max_width = 999, columns = wide}})

	testing.expect_value(t, len(g.template_columns), 1)
}

@(test)
test_grid_breakpoint_wide :: proc(t: ^testing.T) {
	g: Grid
	grid_init(&g, 120)

	narrow := []Track{fr(1)}
	wide := []Track{fr(1), fr(3)}

	grid_breakpoint(&g, []Breakpoint{{max_width = 80, columns = narrow}, {max_width = 999, columns = wide}})

	testing.expect_value(t, len(g.template_columns), 2)
}

@(test)
test_grid_breakpoint_no_match_leaves_columns_unchanged :: proc(t: ^testing.T) {
	g: Grid
	grid_init(&g, 200)
	g.template_columns = []Track{fr(1), fr(1)}

	grid_breakpoint(&g, []Breakpoint{{max_width = 100, columns = []Track{fr(1)}}})

	testing.expect_value(t, len(g.template_columns), 2)
}

@(test)
test_grid_breakpoint_exact_boundary :: proc(t: ^testing.T) {
	g: Grid
	grid_init(&g, 80)

	narrow := []Track{fr(1)}
	wide := []Track{fr(1), fr(3)}

	grid_breakpoint(&g, []Breakpoint{{max_width = 80, columns = narrow}, {max_width = 999, columns = wide}})

	// 80 <= 80, so narrow matches
	testing.expect_value(t, len(g.template_columns), 1)
}
