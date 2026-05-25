package tui

import "core:fmt"
import "core:time"
import style "../style"

// Spinner is an animated indicator for background work.
Spinner :: struct {
	id:       int,           // unique id — routes TickMsgs to the right spinner
	frames:   []string,      // animation frame strings
	frame:    int,           // current frame index
	interval: time.Duration, // time between frames
	active:   bool,
	label:    string,
}

// Built-in frame sets — assign to Spinner.frames after init to change style.
SPINNER_DOTS   := []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
SPINNER_LINE   := []string{"-", "\\", "|", "/"}
SPINNER_BOUNCE := []string{"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"}

// spinner_init sets up a Spinner with dot frames at 80 ms per frame.
spinner_init :: proc(s: ^Spinner, id: int) {
	s.id       = id
	s.frames   = SPINNER_DOTS
	s.frame    = 0
	s.interval = 80 * time.Millisecond
	s.active   = false
	s.label    = "Loading..."
}

// spinner_start marks the spinner active and returns the first tick Cmd.
// Pass the returned Cmd back from app_init or app_update.
spinner_start :: proc(s: ^Spinner) -> Cmd {
	s.active = true
	s.frame  = 0
	return sleep(s.interval, TickMsg{id = s.id})
}

// spinner_stop halts the spinner. The next TickMsg for this spinner is ignored.
spinner_stop :: proc(s: ^Spinner) {
	s.active = false
}

// spinner_update handles a TickMsg for this spinner.
// Returns the next tick Cmd while active, nil when stopped.
spinner_update :: proc(s: ^Spinner, msg: Msg) -> Cmd {
	tick, ok := msg.(TickMsg)
	if !ok           do return nil
	if tick.id != s.id do return nil
	if !s.active     do return nil

	s.frame = (s.frame + 1) % len(s.frames)
	return sleep(s.interval, TickMsg{id = s.id})
}

// spinner_view renders the current frame. Returns "" when inactive.
spinner_view :: proc(s: Spinner) -> string {
	if !s.active do return ""
	frame := s.frames[s.frame % len(s.frames)]
	return fmt.tprintf("%s%s%s %s", style.CYAN, frame, style.RESET, s.label)
}
