package alloy

import style "../style"
import "core:fmt"
import "core:strings"

BoxStyle :: enum {
	Rounded,
	Single,
	Double,
	Heavy,
}

BoxChars :: struct {
	top_left:     string,
	top_right:    string,
	bottom_left:  string,
	bottom_right: string,
	horizontal:   string,
	vertical:     string,
	mid_left:     string, // used for title divider row
	mid_right:    string,
}

box_chars := [BoxStyle]BoxChars {
	.Rounded = {
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
		horizontal = "─",
		vertical = "│",
		mid_left = "├",
		mid_right = "┤",
	},
	.Single = {
		top_left = "┌",
		top_right = "┐",
		bottom_left = "└",
		bottom_right = "┘",
		horizontal = "─",
		vertical = "│",
		mid_left = "├",
		mid_right = "┤",
	},
	.Double = {
		top_left = "╔",
		top_right = "╗",
		bottom_left = "╚",
		bottom_right = "╝",
		horizontal = "═",
		vertical = "║",
		mid_left = "╠",
		mid_right = "╣",
	},
	.Heavy = {
		top_left = "┏",
		top_right = "┓",
		bottom_left = "┗",
		bottom_right = "┛",
		horizontal = "━",
		vertical = "┃",
		mid_left = "┣",
		mid_right = "┫",
	},
}


Box :: struct {
	title:   string,
	width:   int,
	border:  BoxStyle,
	focused: bool,
}

box_init :: proc(box: ^Box, width: int) {
	box.width = width
	box.border = .Rounded
	box.focused = false
}

// box_render wraps lines in a border. Lines must already be width-trimmed.
box_render :: proc(box: Box, lines: []string) -> string {
	chars := box_chars[box.border]

	buf: Buffer
	buffer_init(&buf)
	defer buffer_destroy(&buf)

	border_color := ""
	color_reset := ""
	if box.focused {
		border_color = style.CYAN
		color_reset = style.RESET
	}

	horizontal_line := strings.repeat(chars.horizontal, box.width)
	defer delete(horizontal_line)

	// Top border
	buffer_writef(
		&buf,
		"%s%s%s%s%s\r\n",
		border_color,
		chars.top_left,
		horizontal_line,
		chars.top_right,
		color_reset,
	)

	// Optional title row + divider
	if box.title != "" {
		title_padded := pad_right_visible(box.title, box.width)
		buffer_writef(
			&buf,
			"%s%s%s%s%s%s\r\n",
			border_color,
			chars.vertical,
			color_reset,
			title_padded,
			border_color,
			chars.vertical,
		)
		buffer_write(&buf, color_reset)
		divider := strings.repeat(chars.horizontal, box.width)
		defer delete(divider)
		buffer_writef(
			&buf,
			"%s%s%s%s%s\r\n",
			border_color,
			chars.mid_left,
			divider,
			chars.mid_right,
			color_reset,
		)
	}

	// Content rows
	for line in lines {
		padded := pad_right_visible(line, box.width)
		buffer_writef(
			&buf,
			"%s%s%s%s%s%s\r\n",
			border_color,
			chars.vertical,
			color_reset,
			padded,
			border_color,
			chars.vertical,
		)
		buffer_write(&buf, color_reset)
	}

	// Bottom border
	buffer_writef(
		&buf,
		"%s%s%s%s%s\r\n",
		border_color,
		chars.bottom_left,
		horizontal_line,
		chars.bottom_right,
		color_reset,
	)

	return fmt.tprintf("%s", buffer_string(&buf))
}
