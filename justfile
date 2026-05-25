# Odin project commands

# List available commands
default:
    @just --list

# Enter the Odin dev shell
develop:
    nix develop github:crbroughton/nix-flakes?dir=odin

LINKER_FLAGS := "-lGL -lm -lpthread -ldl -lrt -lX11"

# Run tests for all packages
test:
    -odin test src/style/
    -odin test src/tui/

# Run a component example: just example text_input
example name:
    odin run examples/components/{{name}}/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Run text_input example
example-text-input:
    odin run examples/components/text_input/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Run select example
example-select:
    odin run examples/components/select/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Run spinner example
example-spinner:
    odin run examples/components/spinner/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Run confirm example
example-confirm:
    odin run examples/components/confirm/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Run multiselect example
example-multiselect:
    odin run examples/components/multiselect/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Show project info
info:
    @echo "Odin Demo Project"
    @echo "================="
    @echo "Source: src/main.odin"
