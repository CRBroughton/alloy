![Alloy](assets/social-preview-1280x640.png)

A minimal TUI library for Odin, inspired by Bubble Tea.

## Install

Copy `src/alloy/` into your project's `vendor/` folder:

```sh
cp -r src/alloy/ your-project/vendor/alloy/
```

Then import:

```odin
import alloy "vendor/alloy"
```

## Quick start

```odin
package main

import "core:fmt"
import alloy "vendor/alloy"

Model :: struct { count: int }

my_init :: proc() -> (^Model, alloy.Cmd) {
    return new(Model), nil
}

my_update :: proc(m: ^Model, msg: alloy.Msg) -> (^Model, alloy.Cmd) {
    if km, ok := msg.(alloy.KeyMsg); ok {
        if km.key == .CtrlC do return m, alloy.quit
        if km.key == .Rune && km.rune == '+' do m.count += 1
    }
    return m, nil
}

my_view :: proc(m: ^Model) -> string {
    return fmt.tprintf("Count: %d  (+ to increment, Ctrl+C to quit)\r\n", m.count)
}

main :: proc() {
    alloy.run(&alloy.Program(Model){
        init = my_init,
        update = my_update,
        view = my_view,
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

Use `sleep` to schedule any delayed message, not just spinners:

```odin
import "core:time"

// Deliver a custom message after 2 seconds:
return m, alloy.sleep(2 * time.Second, MyTimeoutMsg{})
```

`sleep` accepts any value that satisfies the `Msg` union; define your own message types in your app.


## Running tests

```sh
just test
```