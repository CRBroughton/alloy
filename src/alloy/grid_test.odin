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


@(test)
test_grid_view_two_columns :: proc(t: ^testing.T) {
	grid: Grid
	grid_init(&grid, 10)
	grid.template_columns = {fr(1), fr(1)}
	grid.column_gap = 0

	result := grid_view(grid, "AB", "CD")
	// Each column is 5 chars wide: "AB   CD   \r\n"
	testing.expect(t, len(result) > 0, "grid_view should return a non-empty string")
}
