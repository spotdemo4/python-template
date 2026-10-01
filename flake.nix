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
    trevpkgs = {
      url = "github:spotdemo4/trevpkgs";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      trevpkgs,
      ...
    }:
    let
      inherit (fromTOML (builtins.readFile ./pyproject.toml)) project;
    in
    trevpkgs.libs.mkFlake (
      system: pkgs:
      let
        python = pkgs.python314;
        dependencies = with python.pkgs; [ ];

        # editable install of this project for development
        editable = python.pkgs.mkPythonEditablePackage {
          pname = project.name;
          inherit (project) version scripts;
          inherit dependencies;
          root = "$REPO_ROOT/src";
        };
        pythonEnv = python.withPackages (_: [ editable ]);
      in
      {
        # nix develop [#...]
        devShells = {
          default = pkgs.mkShell {
            shellHook = ''
              ${pkgs.shellhook.ref}
              unset PYTHONPATH
              export REPO_ROOT=$(git rev-parse --show-toplevel)
            '';
            env = {
              UV_PYTHON = python.interpreter;
              UV_PYTHON_DOWNLOADS = "never";
            };
            packages = with pkgs; [
              # python
              pythonEnv
              uv
              ruff
              pyright

              vscode-json-languageserver # json
              yaml-language-server # yaml
              tombi # toml
              oxfmt # format

              # nix
              nixd
              nixfmt

              # util
              treefmt
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
            ];
          };

          update = pkgs.mkShell {
            packages = with pkgs; [
              renovate

              # python
              python
              uv
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              pysentry # python
              flake-checker # nix
              zizmor # actions
            ];
          };
        };

        # nix build [#...]
        packages = {
          default = python.pkgs.buildPythonPackage (
            final: with pkgs.lib; {
              pname = project.name;
              inherit (project) version;

              src = fileset.toSource {
                root = ./.;
                fileset = fileset.unions [
                  ./pyproject.toml
                  ./LICENSE
                  ./README.md
                  ./src
                ];
              };

              pyproject = true;
              build-system = with python.pkgs; [
                uv-build-latest
              ];
              inherit dependencies;

              pythonImportsCheck = [ "python_template" ];
              checkPhase = ''
                runHook preCheck
                test "$("$out/bin/python-template")" = "Hello, world!"
                runHook postCheck
              '';

              meta = {
                mainProgram = "python-template";
                description = "python template";
                license = licenses.mit;
                platforms = platforms.all;
                homepage = "https://trev.zip/template/python";
                changelog = "https://trev.zip/template/python/releases";
                downloadPage = "https://trev.zip/template/python/releases/tag/v${final.version}";
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
            ruff
            oxfmt
            nixfmt
          ];
        };

        # nix flake check
        checks = pkgs.mkChecks {
          package = self.packages.${system}.default;

          python = {
            root = ./.;
            filter = file: file.hasExt "py";
            include = [
              ./.python-version
              ./pyproject.toml
              ./uv.lock
            ];
            packages = with pkgs; [
              pythonEnv
              ruff
              pyright
            ];
            script = ''
              ruff check
              pyright --warnings
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            packages = with pkgs; [
              nixfmt
            ];
            script = ''
              nixfmt --check "$file"
            '';
          };

          actions-gh = {
            root = ./.github/workflows;
            filter = file: file.hasExt "yaml";
            packages = with pkgs; [
              action-validator
              zizmor
            ];
            script = ''
              action-validator "$file"
              zizmor --offline "$file"
            '';
          };

          actions-fj = {
            root = ./.forgejo/workflows;
            filter = file: file.hasExt "yaml";
            packages = with pkgs; [
              forgejo-runner
              zizmor
            ];
            script = ''
              forgejo-runner validate --workflow --path "$file"
              zizmor --offline "$file"
            '';
          };

          renovate-gh = {
            root = ./.github;
            files = ./.github/renovate.json;
            packages = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          renovate-fj = {
            root = ./.forgejo;
            files = ./.forgejo/renovate.json;
            packages = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          config = {
            root = ./.;
            filter = file: file.hasExt "json" || file.hasExt "yaml" || file.hasExt "toml" || file.hasExt "md";
            packages = with pkgs; [
              oxfmt
            ];
            script = ''
              oxfmt --check
            '';
          };
        };
      }
    );
}
