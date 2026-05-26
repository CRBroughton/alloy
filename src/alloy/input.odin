package alloy

import "core:os"
import components "../components"

// read_key blocks until a keypress is available, then returns a KeyMsg.
// Call this in a loop from a background thread (see chapter 6).
read_key :: proc() -> KeyMsg {
	buf: [8]byte
	n, err := os.read(os.stdin, buf[:])
	if err != nil || n == 0 {
		return KeyMsg{key = .Unknown}
	}
	return components.parse_key(buf[:n])
}
