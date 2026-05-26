package forge

import "core:fmt"
import "core:os"
import posix "core:sys/posix"
import components "../alloy-components"

// raw_mode_enter puts the terminal into raw mode WITHOUT entering the
// alternate screen buffer. Completed step output stays in scroll history.
raw_mode_enter :: proc() -> posix.termios {
	original: posix.termios
	rc := posix.tcgetattr(posix.STDIN_FILENO, &original)
	if rc != .OK {
		fmt.eprintfln("forge: tcgetattr failed: %v", rc)
		return original
	}

	raw := original
	raw.c_iflag &~= {.BRKINT, .ICRNL, .INPCK, .ISTRIP, .IXON}
	raw.c_oflag &~= {.OPOST}
	raw.c_cflag |= {.CS8}
	raw.c_lflag &~= {.ECHO, .ICANON, .IEXTEN, .ISIG}
	raw.c_cc[.VMIN]  = 1
	raw.c_cc[.VTIME] = 0

	posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &raw)
	return original
}

// raw_mode_exit restores the terminal to its original state.
raw_mode_exit :: proc(original: posix.termios) {
	restored := original
	posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &restored)
}

// read_key blocks until a keypress is available, then returns a Msg.
read_key :: proc() -> Msg {
	buf: [8]byte
	n, err := os.read(os.stdin, buf[:])
	if err != nil || n == 0 {
		return KeyMsg{key = .Unknown}
	}
	return Msg(components.parse_key(buf[:n]))
}
