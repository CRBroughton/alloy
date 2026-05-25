# Changelog

All notable changes to Alloy are documented here.

## [0.0.1] - 2026-05-25

### Documentation

- Add README
- Add social preview, add to README *(docs)*
- Update README with same naming convention we recommend in the installation step *(docs)*

### Features

- Create very basic ANSI colour coding system *(ansi)*
- Create the types map for keys, messages, and general commands *(types)*
- Create the various program states, and runner (not actually implemented the runner yet, still learning) *(program)*
- Create a demo app (only initialising, doesn't actually work)
- Create buffer.odin *(tui)*
- Implement TEA event loop with alternate screen buffer *(tui)*
- Add TextInput component and update demo app *(tui)*
- Add Select component with keyboard navigation *(tui)*
- Update demo app to showcase Select component
- Add Spinner component and async Cmd dispatch *(tui)*
- Update demo app to showcase Spinner component
- Create the confirm component, add example to main.odin *(tui)*
- Creat the multiselect component, add tests, update just comands and documentation *(tui)*
- Add sleep() helper proc *(tui)*

### Refactoring

- Rename ansi to style (avoid the existing built in ansi), add tests and just file command to run said tests *(style)*
- Replace wrap pointer call with parametric generic type model *(tui)*
- Move MultiSelect result into component state *(tui)*
- Rename tui package to alloy *(tui)*

### Testing

- Add passing tests for types *(tui)*
- Add smoke tests for the publicly facing API's *(tui)*


