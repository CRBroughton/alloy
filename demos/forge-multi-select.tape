Output demos/forge-multi-select.gif

Set FontSize 14
Set Width 900
Set Height 500
Set Theme "Dracula"
Set Shell "bash"
Set PlaybackSpeed 1

# Build first
Exec "just build-all 2>/dev/null; true"

# Run the example
Type "./build/forge-multi-select"
Enter
Sleep 500ms

# Project name step — type a name and submit
Type "my-nuxt-app"
Sleep 300ms
Enter
Sleep 400ms

# Multi-select step
# ESLint is pre-checked (default = true)
# Toggle Prettier on
Down
Space
Sleep 300ms
# Skip Husky
Down
Sleep 200ms
# Toggle Testing Library on
Down
Space
Sleep 300ms
Enter
Sleep 400ms

# Confirm: Install dependencies? — default Yes
Enter
Sleep 500ms

# Tasks running (1000 + 1500 + 2000ms)
Sleep 5000ms
