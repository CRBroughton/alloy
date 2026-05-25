package ansi

import "core:fmt"
RESET :: "\033[0m"

// Foreground colours
BLACK :: "\033[30m"
RED :: "\033[31m"
GREEN :: "\033[32m"
YELLOW :: "\033[33m"
BLUE :: "\033[34m"
MAGENTA :: "\033[35m"
CYAN :: "\033[36m"
WHITE :: "\033[37m"

// Bright variants
BRIGHT_BLACK :: "\033[90m"
BRIGHT_RED :: "\033[91m"
BRIGHT_GREEN :: "\033[92m"
BRIGHT_YELLOW :: "\033[93m"
BRIGHT_BLUE :: "\033[94m"
BRIGHT_MAGENTA :: "\033[95m"
BRIGHT_CYAN :: "\033[96m"
BRIGHT_WHITE :: "\033[97m"

// Styles
BOLD :: "\033[1m"
DIM :: "\033[2m"
ITALIC :: "\033[3m"
UNDERLINE :: "\033[4m"

// Cursor / screen control
CLEAR_SCREEN :: "\033[2J"
CLEAR_LINE :: "\033[2K"
CURSOR_HOME :: "\033[H"
CURSOR_HIDE :: "\033[?25l"
CURSOR_SHOW :: "\033[?25h"

CURSOR_UP_FMT :: "\033[%dA"

colorise :: proc(text: string, color: string) -> string {
	return fmt.tprintf("%s%s%s", color, text, RESET)
}
