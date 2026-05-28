package alloy

import style "../style"
import "core:fmt"
import "core:strings"
import "core:unicode/utf8"

// visible_len returns the number of visible (non-ANSI-escape) rune characters in s.
visible_len :: proc(s: string) -> int {
	count := 0
	in_escape := false
	for ch in s {
		if ch == '\x1b' {
			in_escape = true
			continue
		}
		if in_escape {
			if ch == 'm' do in_escape = false
			continue
		}
		count += 1
	}
	return count
}

// pad_right_visible pads s to width visible characters with trailing spaces.
// Handles ANSI escape codes correctly — styled strings align without bias.
pad_right_visible :: proc(s: string, width: int) -> string {
	current_width := visible_len(s)
	if current_width >= width do return s
	padding := strings.repeat(" ", width - current_width)
	defer delete(padding)
	return fmt.tprintf("%s%s", s, padding)
}

// truncate cuts s to max_width visible characters, appending "…" if cut.
// ANSI codes are preserved up to the cut point and reset after.
truncate :: proc(s: string, max_width: int) -> string {
	if visible_len(s) <= max_width do return s

	buf: strings.Builder
	strings.builder_init(&buf)

	visible := 0
	i := 0
	for i < len(s) {
		ch, size := utf8.decode_rune_in_string(s[i:])

		if ch == '\x1b' {
			// Copy escape sequence verbatim up to and including 'm'
			j := i + 1
			for j < len(s) && s[j] != 'm' {
				j += 1
			}
			if j < len(s) do j += 1
			strings.write_string(&buf, s[i:j])
			i = j
			continue
		}

		if visible >= max_width - 1 {
			strings.write_string(&buf, style.RESET)
			strings.write_rune(&buf, '…')
			break
		}

		strings.write_rune(&buf, ch)
		visible += 1
		i += size
	}

	result := fmt.tprintf("%s", strings.to_string(buf))
	strings.builder_destroy(&buf)
	return result
}

// wrap breaks s into lines of at most width visible characters.
// Breaks on word boundaries where possible. Returns lines joined by \r\n.
wrap :: proc(s: string, width: int) -> string {
	if visible_len(s) <= width do return s

	words := strings.split(s, " ")
	defer delete(words)

	buf: strings.Builder
	strings.builder_init(&buf)

	line_len := 0
	for word in words {
		wl := visible_len(word)
		if line_len + wl + (1 if line_len > 0 else 0) > width {
			if line_len > 0 {
				strings.write_string(&buf, "\r\n")
				line_len = 0
			}
		} else if line_len > 0 {
			strings.write_byte(&buf, ' ')
			line_len += 1
		}
		strings.write_string(&buf, word)
		line_len += wl
	}

	result := fmt.tprintf("%s", strings.to_string(buf))
	strings.builder_destroy(&buf)
	return result
}
