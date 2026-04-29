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
      system: pkgs: {

        # nix develop [#...]
        devShells = {
          default = pkgs.mkShell {
            shellHook = pkgs.shellhook.ref;
            packages = with pkgs; [
              # python
              python314
              uv

              # lint
              ruff
              nixd

              # format
              treefmt
              prettier
              nixfmt

              # util
              bumper
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
              flake-checker # nix
              zizmor # actions
              pysentry # python
            ];
          };
        };

        # nix run [#...]
        apps = pkgs.mkApps {
          default = "uv run spotdemo4-python-template";
        };

        # nix build [#...]
        packages = {
          default = pkgs.python314Packages.buildPythonPackage (
            final: with pkgs.lib; {
              pname = "python-template";
              version = "0.1.1";

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
                uv-build-latest
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
        };

        # nix build #images.[...]
        images = {
          default = pkgs.mkImage {
            src = self.packages.${system}.default;
          };
        };

        # nix build #appimages.[...]
        appimages = {
          default = pkgs.mkAppImage {
            src = self.packages.${system}.default;
          };
        };

        # nix fmt
        formatter = pkgs.treefmt.withConfig {
          configFile = ./treefmt.toml;
          runtimeInputs = with pkgs; [
            prettier
            nixfmt
            ruff
          ];
        };

        # nix flake check
        checks = pkgs.mkChecks {
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

          actions = {
            root = ./.github/workflows;
            filter = file: file.hasExt "yaml";
            packages = with pkgs; [
              action-validator
              zizmor
            ];
            forEach = ''
              action-validator "$file"
              zizmor --offline "$file"
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

          python = {
            src = self.packages.${system}.default;
            packages = with pkgs; [
              ruff
            ];
            script = ''
              ruff check
            '';
          };
        };
      }
    );
}
