Output demos/forge-multi-select.webm

Set FontSize 28
Set Width 1400
Set Height 700
Set Shell "fish"
Set PlaybackSpeed 1
Set TypingSpeed 100ms
Hide
Type "export PS1='$ ' && clear"
Enter
Sleep 300ms
Show

# Run the example
Type "./build/forge-multi-select"
Enter
Sleep 500ms

# Project name step — type a name and submit
Type "my-nuxt-app"
Sleep 500ms
Enter
Sleep 500ms

# Multi-select step
# ESLint is pre-checked (default = true)
# Toggle Prettier on
Down
Space
Sleep 500ms
# Skip Husky
Down
Sleep 500ms
# Toggle Testing Library on
Down
Space
Sleep 500ms
Enter
Sleep 500ms

# Confirm: Install dependencies? — default Yes
Enter
Sleep 500ms

# Tasks running (1000 + 1500 + 2000ms)
Sleep 5000ms
