package components

import "core:unicode/utf8"

// parse_key converts a raw byte sequence into a KeyMsg.
parse_key :: proc(buf: []byte) -> KeyMsg {
	if len(buf) == 0 do return KeyMsg{key = .Unknown}

	switch buf[0] {
	case 0x03:
		return KeyMsg{key = .CtrlC}
	case 0x04:
		return KeyMsg{key = .CtrlD}
	case 0x09:
		return KeyMsg{key = .Tab}
	case 0x0C:
		return KeyMsg{key = .CtrlL}
	case 0x0D:
		return KeyMsg{key = .Enter}
	case 0x7F:
		return KeyMsg{key = .Backspace}

	case 0x1B:
		if len(buf) == 1 do return KeyMsg{key = .Escape}
		if len(buf) >= 3 && buf[1] == '[' {
			return parse_escape_sequence(buf[2:])
		}
		return KeyMsg{key = .Escape}

	case 0x20:
		return KeyMsg{key = .Space}

	case:
		if buf[0] >= 32 && buf[0] < 127 || buf[0] >= 0x80 {
			r, _ := utf8.decode_rune(buf)
			return KeyMsg{key = .Rune, rune = r}
		}
		return KeyMsg{key = .Unknown}
	}
}

// parse_escape_sequence handles bytes after ESC[
parse_escape_sequence :: proc(buf: []byte) -> KeyMsg {
	if len(buf) == 0 do return KeyMsg{key = .Escape}

	switch buf[0] {
	case 'A':
		return KeyMsg{key = .Up}
	case 'B':
		return KeyMsg{key = .Down}
	case 'C':
		return KeyMsg{key = .Right}
	case 'D':
		return KeyMsg{key = .Left}
	case 'H':
		return KeyMsg{key = .Home}
	case 'F':
		return KeyMsg{key = .End}
	case '1':
		if len(buf) >= 2 && buf[1] == '~' do return KeyMsg{key = .Home}
	case '3':
		if len(buf) >= 2 && buf[1] == '~' do return KeyMsg{key = .Delete}
	case '4':
		if len(buf) >= 2 && buf[1] == '~' do return KeyMsg{key = .End}
	case '5':
		if len(buf) >= 2 && buf[1] == '~' do return KeyMsg{key = .PageUp}
	case '6':
		if len(buf) >= 2 && buf[1] == '~' do return KeyMsg{key = .PageDown}
	}

	return KeyMsg{key = .Unknown}
}
