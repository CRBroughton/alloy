# Odin project commands

# List available commands
default:
    @just --list

# Enter the Odin dev shell
develop:
    nix develop github:crbroughton/nix-flakes?dir=odin

LINKER_FLAGS := "-lm -lpthread -ldl -lrt"

# Run tests for all packages
test:
    -odin test src/style/
    -odin test src/alloy-components/
    -odin test src/alloy/
    -odin test src/forge/

# Run forge tests only
test-forge:
    odin test src/forge/

# Run component tests only
test-components:
    odin test src/alloy-components/

# Build all examples into build/ (no execution; used in CI)
build-all:
    mkdir -p build
    odin build examples/counter/                -out:build/counter        -extra-linker-flags:"{{LINKER_FLAGS}}"
    odin build examples/components/text_input/  -out:build/text_input     -extra-linker-flags:"{{LINKER_FLAGS}}"
    odin build examples/components/select/      -out:build/select         -extra-linker-flags:"{{LINKER_FLAGS}}"
    odin build examples/components/spinner/     -out:build/spinner        -extra-linker-flags:"{{LINKER_FLAGS}}"
    odin build examples/components/confirm/     -out:build/confirm        -extra-linker-flags:"{{LINKER_FLAGS}}"
    odin build examples/components/multiselect/ -out:build/multiselect    -extra-linker-flags:"{{LINKER_FLAGS}}"
    odin build examples/components/grid/        -out:build/grid            -extra-linker-flags:"{{LINKER_FLAGS}}"
    odin build examples/components/box/         -out:build/box             -extra-linker-flags:"{{LINKER_FLAGS}}"
    odin build examples/forge/step/             -out:build/forge-step      -extra-linker-flags:"{{LINKER_FLAGS}}"

# Remove build artifacts
clean:
    rm -rf build/

# Run forge step example
example-forge-step:
    mkdir -p build
    odin build examples/forge/step/ -out:build/forge-step -extra-linker-flags:"{{LINKER_FLAGS}}"
    ./build/forge-step

# Run box example
example-box:
    odin run examples/components/box/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Run grid example
example-grid:
    odin run examples/components/grid/ -extra-linker-flags:"{{LINKER_FLAGS}}"

# Run counter example
example-counter:
    odin run examples/counter/ -extra-linker-flags:"{{LINKER_FLAGS}}"

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

# Preview unreleased changelog entries
changelog-preview:
    git cliff --unreleased

# Write full CHANGELOG.md
changelog:
    git cliff -o CHANGELOG.md

# Tag a new release and update CHANGELOG.md: just release v0.1.0
release tag:
    git cliff --tag {{tag}} -o CHANGELOG.md
    git add CHANGELOG.md
    git commit -m "chore(release): :bookmark: prepare {{tag}}"
    git tag -a {{tag}} -m "Release {{tag}}"
    @echo "Run: git push && git push origin {{tag}}"
