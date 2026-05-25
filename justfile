# Odin project commands

# List available commands
default:
    @just --list

# Enter the Odin dev shell
develop:
    nix develop github:crbroughton/nix-flakes?dir=odin

LINKER_FLAGS := "-lGL -lm -lpthread -ldl -lrt -lX11"

# Run the project
run:
    odin run src/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Build debug binary
build:
    odin build src/ -out:main -extra-linker-flags:"{{LINKER_FLAGS}}"

# Build optimised release binary
release:
    odin build src/ -out:main -o:speed -extra-linker-flags:"{{LINKER_FLAGS}}"

# Clean build artifacts
clean:
    rm -f main

# Run tests for all packages
test:
    -odin test src/
    -odin test src/style/
    -odin test src/tui/

# Show project info
info:
    @echo "Odin Demo Project"
    @echo "================="
    @echo "Source: src/main.odin"
