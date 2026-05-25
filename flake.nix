{
  description = "Odin Development Flake: A hybrid package and module provider.";

  /*
    📘 NEW ENGINEER GUIDE: THE HYBRID FLAKE PATTERN
    ===============================================
    This file demonstrates a powerful Nix pattern that serves two purposes:
    1. It is a Package Provider: It builds a custom Odin environment.
    2. It is a Module Provider: It exports a Home Manager module to install that environment.

    The file is split into two halves, combined by the `//` merge operator.
    - PART 1: Builds the software (system-specific).
    - PART 2: Configures the software (system-agnostic).
  */

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:

    # =========================================================================
    # PART 1: SYSTEM-SPECIFIC OUTPUTS (The Builder)
    # =========================================================================
    # We use `flake-utils` to loop over every standard architecture (Linux, Mac).
    # Everything inside this block is calculated separately for "x86_64-linux", etc.
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # [Step A] Version map — compiler + language server for each supported release.
        # nixpkgs currently ships a single Odin build (a dev/monthly snapshot).
        # Add new entries here when additional versioned packages appear upstream.
        versions = {
          "latest" = { compiler = pkgs.odin; lsp = pkgs.ols; };
        };

        # [Step B] Raylib version map.
        # Odin's vendored bindings emit -lraylib at link time; without raylib in
        # the shell's buildInputs, nix won't add its lib path and the link fails.
        # Add new entries here when additional versioned packages appear upstream.
        raylibVersions = {
          "latest" = pkgs.raylib;
        };

        # System libraries that raylib always needs at link time regardless of version.
        raylibSysDeps = [ pkgs.libGL pkgs.libx11 ];

        # Helper: build a mkShell for a given odin + raylib version pairing.
        mkOdinShell = v: rl: pkgs.mkShell {
          buildInputs = [ v.compiler v.lsp rl ] ++ raylibSysDeps;
        };

        # [Step B] Create an "Installable" Environment (CRITICAL CONCEPT)
        # Home Manager requires a DIRECTORY of binaries to install.
        # `pkgs.mkShell` (used for devShells) creates a shell script, which HM cannot install.
        # `pkgs.buildEnv` creates a proper directory structure (bin/, lib/) HM can use.
        odinEnvPackage = pkgs.buildEnv {
          name = "odin-dev-env";
          paths = [ versions."latest".compiler versions."latest".lsp ];
        };

      in
      {
        # OUTPUT 1: The Installable Package
        # Used by: Home Manager (see Part 2) or `nix profile install`
        packages.default = odinEnvPackage;

        # OUTPUT 2: Named Development Shells — one per supported Odin version.
        # Raylib defaults to "latest" in all shells; override by editing raylibVersions
        # and passing the desired entry to mkOdinShell if per-shell pinning is needed.
        # Usage:
        #   nix develop   → latest Odin + latest raylib
        devShells = builtins.mapAttrs (_: v: mkOdinShell v raylibVersions."latest") versions // {
          default = mkOdinShell versions."latest" raylibVersions."latest";
        };
      }
    )

    # =========================================================================
    # PART 2: TOP-LEVEL OUTPUTS (The Configurator)
    # =========================================================================
    # The `//` operator merges the system-specific map (above) with the global map (below).
    # Modules are system-agnostic code, so they live here, outside the system loop.
    // {
      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        with lib;
        let
          cfg = config.programs.odin;
          startupMessage = "Odin development environment activated!";

          # Version maps mirror Part 1 — add entries here and in Part 1 together.
          versionMap = {
            "latest" = { compiler = pkgs.odin; lsp = pkgs.ols; };
          };

          raylibVersionMap = {
            "latest" = pkgs.raylib;
          };

          selected        = versionMap.${cfg.version};
          selectedRaylib  = raylibVersionMap.${cfg.raylibVersion};

          # ols binary path — used to override the VSCode extension's downloaded binary.
          # The danielgavin.ols extension downloads a generic Linux binary that NixOS
          # cannot run. Pointing ols.server.path at the Nix store binary fixes this.
          olsBin = "${selected.lsp}/bin/ols";

        in
        {
          # 1. THE INTERFACE
          # We define options that users can toggle in their home.nix
          # Usage:
          #   programs.odin.enable = true;
          #   programs.odin.version = "latest"; # only option currently available
          options.programs.odin = {
            enable = mkEnableOption "Odin development environment";

            version = mkOption {
              type = types.enum [ "latest" ];
              default = "latest";
              description = ''
                Odin version to install. Currently nixpkgs ships a single
                dev/monthly snapshot; more entries will be added as versioned
                packages become available upstream.
              '';
            };

            raylibVersion = mkOption {
              type = types.enum [ "latest" ];
              default = "latest";
              description = ''
                Raylib version to install alongside Odin. Currently nixpkgs ships
                a single build (5.5-unstable); more entries will be added as
                versioned packages become available upstream.
              '';
            };
          };

          # 2. THE IMPLEMENTATION
          # If the user enables the module, this config block is applied.
          config = mkIf cfg.enable {

            # A. Install the Package
            # --------------------
            # We must reference the package we built in Part 1.
            # `self` refers to this very flake.
            # `pkgs.stdenv.hostPlatform.system` automatically picks the correct
            # architecture (e.g., x86_64-linux) for the user's machine.
            home.packages = [ selected.compiler selected.lsp selectedRaylib pkgs.libGL pkgs.libx11 ];

            # B. Configure the Editor
            # ---------------------
            # We can also configure other tools, like VS Code extensions.
            programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
              tetralux.odin-lang
              danielgavin.ols
            ];

            # Point the extension at the Nix-provided ols binary.
            # Without this, the extension downloads a generic Linux binary which NixOS
            # cannot execute (dynamically linked against a foreign /lib).
            programs.vscode.profiles.default.userSettings = {
              "ols.server.path" = olsBin;
            };

            # C. Run Activation Scripts
            # -----------------------
            # Optional: Scripts to run after the generation switches.
            home.activation.odinInfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              echo "${startupMessage}"
            '';
          };
        };
    };
}
