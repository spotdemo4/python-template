{
  description = "python template";

  nixConfig = {
    extra-substituters = [
      "https://nix.trev.zip"
    ];
    extra-trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
    ];
  };

  inputs = {
    systems.url = "github:spotdemo4/systems";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    trev = {
      url = "github:spotdemo4/nur";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      trev,
      ...
    }:
    trev.libs.mkFlake (
      system: init:
      let
        pkgs = init.appendOverlays [ trev.overlays.python ];
      in
      {
        devShells = {
          default = pkgs.mkShell {
            shellHook = pkgs.shellhook.ref;
            packages = with pkgs; [
              # python
              python314
              uv

              # lint
              ruff

              # format
              nixfmt
              prettier

              # util
              bumper
              flake-release
            ];
          };

          bump = pkgs.mkShell {
            packages = with pkgs; [
              bumper
            ];
          };

          release = pkgs.mkShell {
            packages = with pkgs; [
              flake-release

              # python
              python314
              uv
            ];
          };

          update = pkgs.mkShell {
            packages = with pkgs; [
              renovate

              # python
              python314
              uv
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              pysentry # python
              flake-checker # flake
              octoscan # actions
            ];
          };
        };

        apps = pkgs.mkApps {
          default = "uv run spotdemo4-python-template";
        };

        checks = pkgs.mkChecks {
          python = {
            src = self.packages.${system}.default;
            packages = with pkgs; [
              ruff
            ];
            script = ''
              ruff check
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            packages = with pkgs; [
              nixfmt
            ];
            forEach = ''
              nixfmt --check "$file"
            '';
          };

          renovate = {
            root = ./.github;
            files = ./.github/renovate.json;
            packages = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          actions = {
            root = ./.;
            files = [
              ./action.yaml
              ./.github/workflows
            ];
            packages = with pkgs; [
              action-validator
              octoscan
            ];
            forEach = ''
              action-validator "$file"
              octoscan scan "$file"
            '';
          };

          prettier = {
            root = ./.;
            filter = file: file.hasExt "yaml" || file.hasExt "json" || file.hasExt "md";
            packages = with pkgs; [
              prettier
            ];
            forEach = ''
              prettier --check "$file"
            '';
          };
        };

        formatter = pkgs.treefmt.withConfig {
          configFile = ./treefmt.toml;
          runtimeInputs = with pkgs; [
            ruff
            nixfmt
            prettier
          ];
        };

        packages.default = pkgs.python314Packages.buildPythonPackage (
          final: with pkgs.lib; {
            pname = "python-template";
            version = "0.1.0";

            src = fileset.toSource {
              root = ./.;
              fileset = fileset.unions [
                ./.python-version
                ./pyproject.toml
                ./LICENSE
                ./README.md
                ./uv.lock
                ./src
              ];
            };

            pyproject = true;
            build-system = with pkgs.python314Packages; [
              setuptools
              uv-build
            ];

            meta = {
              mainProgram = "spotdemo4-python-template";
              description = "Python template";
              license = licenses.mit;
              platforms = platforms.all;
              homepage = "https://github.com/spotdemo4/python-template";
              changelog = "https://github.com/spotdemo4/python-template/releases/tag/v${final.version}";
              downloadPage = "https://github.com/spotdemo4/python-template/releases/tag/v${final.version}";
            };
          }
        );

        images.default = pkgs.mkImage {
          src = self.packages.${system}.default;
        };

        appimages.default = pkgs.mkAppImage {
          src = self.packages.${system}.default;
        };

        schemas = trev.schemas;
      }
    );
}
