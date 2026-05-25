# Alloy

A minimal TUI library for Odin, inspired by Bubble Tea.

## Install

Copy `src/tui/` into your project's `vendor/` folder:

```sh
cp -r src/tui/ your-project/vendor/tui/
```

Then import:

```odin
import tui "vendor/tui"
```

## Quick start

```odin
package main

import "core:fmt"
import tui "vendor/tui"

Model :: struct { count: int }

my_init :: proc() -> (rawptr, tui.Cmd) {
    m := new(Model)
    return m, nil
}

my_update :: proc(raw: rawptr, msg: tui.Msg) -> (rawptr, tui.Cmd) {
    m := cast(^Model)raw
    if km, ok := msg.(tui.KeyMsg); ok {
        if km.key == .CtrlC                        do return raw, tui.quit
        if km.key == .Rune && km.rune == '+' do m.count += 1
    }
    return raw, nil
}

my_view :: proc(raw: rawptr) -> string {
    m := cast(^Model)raw
    return fmt.tprintf("Count: %d  (+ to increment, Ctrl+C to quit)\r\n", m.count)
}

main :: proc() {
    tui.run(&tui.Program{
        init   = my_init,
        update = my_update,
        view   = my_view,
    })
}
```

## Components

- **TextInput**: single-line text field with cursor, placeholder, and focus state
- **Select**: keyboard-navigable option list; returns `SelectDoneMsg` on confirm
- **Spinner**: animated indicator driven by a self-scheduling `SleepCmd` timer
- **Confirm**: yes/no prompt with configurable default; returns `ConfirmMsg` on answer
- **MultiSelect**: checkbox list; Space to toggle, Enter to confirm; returns `MultiSelectDoneMsg`

---

## Timer-based commands

Use `SleepCmd` to schedule any delayed message — not just spinners:

```odin
import "core:time"

// Deliver a custom message after 2 seconds:
return raw, tui.SleepCmd{
    duration = 2 * time.Second,
    then     = MyTimeoutMsg{},
}
```

Add `MyTimeoutMsg` to the `Msg` union in `types.odin`.


## Running tests

```sh
odin test src/tui/
# or
just test
```