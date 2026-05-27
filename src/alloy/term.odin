package alloy

import "core:c"
import "core:fmt"
import "core:os"
import posix "core:sys/posix"

// TIOCGWINSZ ioctl request code for "get window size".
// Linux and Darwin use different values.
when ODIN_OS == .Linux {
	TIOCGWINSZ :: c.ulong(0x5413)
	foreign import libc "system:c"
} else when ODIN_OS == .Darwin {
	TIOCGWINSZ :: c.ulong(0x40087468)
	foreign import libc "system:System.framework"
}

@(default_calling_convention = "c")
foreign libc {
	@(link_name = "ioctl")
	_ioctl :: proc(fd: c.int, request: c.ulong, arg: rawptr) -> c.int ---
}

// Winsize mirrors the kernel's struct winsize returned by TIOCGWINSZ.
Winsize :: struct {
	ws_row:    u16,
	ws_col:    u16,
	ws_xpixel: u16,
	ws_ypixel: u16,
}

Term :: struct {
	original: posix.termios,
	raw:      posix.termios,
	is_raw:   bool,
}

// term_init saves the current terminal state.
// Call this once at program startup.
term_init :: proc(t: ^Term) -> bool {
	rc := posix.tcgetattr(posix.STDIN_FILENO, &t.original)
	if rc != .OK {
		fmt.eprintfln("tui: tcgetattr failed: %v", rc)
		return false
	}
	t.raw = t.original
	t.is_raw = false
	return true
}

// term_raw puts the terminal into raw mode.
term_raw :: proc(t: ^Term) -> bool {
	if t.is_raw do return true

	raw := t.raw

	raw.c_iflag &~= {.BRKINT, .ICRNL, .INPCK, .ISTRIP, .IXON}
	raw.c_oflag &~= {.OPOST}
	raw.c_cflag |= {.CS8}
	raw.c_lflag &~= {.ECHO, .ICANON, .IEXTEN, .ISIG}
	raw.c_cc[.VMIN] = 1
	raw.c_cc[.VTIME] = 0

	rc := posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &raw)
	if rc != .OK {
		fmt.eprintfln("tui: tcsetattr failed: %v", rc)
		return false
	}

	t.raw = raw
	t.is_raw = true
	return true
}

// term_restore returns the terminal to its original cooked mode.
term_restore :: proc(t: ^Term) {
	if !t.is_raw do return
	posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &t.original)
	t.is_raw = false
}

// term_size returns the current terminal width and height in columns/rows.
term_size :: proc() -> (width: int, height: int) {
	ws: Winsize
	_ioctl(0, TIOCGWINSZ, &ws)
	return int(ws.ws_col), int(ws.ws_row)
}

// term_clear writes ANSI codes to clear the screen and home the cursor.
term_clear :: proc() {
	os.write_string(os.stdout, "\x1b[2J\x1b[H")
}

// term_move_cursor writes an ANSI code to move the cursor to row, col (1-based).
term_move_cursor :: proc(row: int, col: int) {
	fmt.printf("\x1b[%d;%dH", row, col)
}
