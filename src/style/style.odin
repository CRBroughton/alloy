package style

import "core:fmt"

RESET :: "\x1b[0m"

// Foreground colours
BLACK   :: "\x1b[30m"
RED     :: "\x1b[31m"
GREEN   :: "\x1b[32m"
YELLOW  :: "\x1b[33m"
BLUE    :: "\x1b[34m"
MAGENTA :: "\x1b[35m"
CYAN    :: "\x1b[36m"
WHITE   :: "\x1b[37m"

// Bright variants
BRIGHT_BLACK   :: "\x1b[90m"
BRIGHT_RED     :: "\x1b[91m"
BRIGHT_GREEN   :: "\x1b[92m"
BRIGHT_YELLOW  :: "\x1b[93m"
BRIGHT_BLUE    :: "\x1b[94m"
BRIGHT_MAGENTA :: "\x1b[95m"
BRIGHT_CYAN    :: "\x1b[96m"
BRIGHT_WHITE   :: "\x1b[97m"

// Styles
BOLD      :: "\x1b[1m"
DIM       :: "\x1b[2m"
ITALIC    :: "\x1b[3m"
UNDERLINE :: "\x1b[4m"

// Cursor / screen control
CLEAR_SCREEN :: "\x1b[2J"
CLEAR_LINE   :: "\x1b[2K"
CURSOR_HOME  :: "\x1b[H"
CURSOR_HIDE  :: "\x1b[?25l"
CURSOR_SHOW  :: "\x1b[?25h"

CURSOR_UP_FMT :: "\x1b[%dA"

colorise :: proc(text: string, color: string) -> string {
	return fmt.tprintf("%s%s%s", color, text, RESET)
}
