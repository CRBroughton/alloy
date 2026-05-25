package tui

import "core:fmt"
import "core:strings"

Buffer :: struct {
	b: strings.Builder,
}

buffer_init :: proc(buf: ^Buffer) {
	strings.builder_init(&buf.b)
}

buffer_destroy :: proc(buf: ^Buffer) {
	strings.builder_destroy(&buf.b)
}

buffer_reset :: proc(buf: ^Buffer) {
	strings.builder_reset(&buf.b)
}

buffer_write :: proc(buf: ^Buffer, s: string) {
	strings.write_string(&buf.b, s)
}

buffer_writeln :: proc(buf: ^Buffer, s: string) {
	strings.write_string(&buf.b, s)
	strings.write_byte(&buf.b, '\n')
}

buffer_writef :: proc(buf: ^Buffer, format: string, args: ..any) {
	fmt.sbprintf(&buf.b, format, ..args)
}

buffer_string :: proc(buf: ^Buffer) -> string {
	return strings.to_string(buf.b)
}
