package tui

CURSOR_HIDE   :: "\x1b[?25l"
CURSOR_SHOW   :: "\x1b[?25h"
CLEAR_SCREEN  :: "\x1b[2J"
CURSOR_HOME   :: "\x1b[H"
CLEAR_LINE    :: "\x1b[2K"
CURSOR_UP_FMT :: "\x1b[%dA"

// Alternate screen buffer — enter/exit a separate display with no scrollback.
// All TUI programs (vim, htop, etc.) use this to avoid polluting the terminal history.
ALT_SCREEN_ENTER :: "\x1b[?1049h"
ALT_SCREEN_EXIT  :: "\x1b[?1049l"
