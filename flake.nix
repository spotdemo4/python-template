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
    systems.url = "github:nix-systems/default";
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
              renovate
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
              python314
              uv
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              # python
              pysentry

              # flake
              flake-checker

              # actions
              octoscan
            ];
          };
        };

        checks = pkgs.mkChecks {
          python = {
            src = self.packages.${system}.default;
            deps = with pkgs; [
              ruff
            ];
            script = ''
              ruff check
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            deps = with pkgs; [
              nixfmt
            ];
            forEach = ''
              nixfmt --check "$file"
            '';
          };

          renovate = {
            root = ./.github;
            fileset = ./.github/renovate.json;
            deps = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          actions = {
            root = ./.;
            fileset = pkgs.lib.fileset.unions [
              ./action.yaml
              ./.github/workflows
            ];
            deps = with pkgs; [
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
            deps = with pkgs; [
              prettier
            ];
            forEach = ''
              prettier --check "$file"
            '';
          };
        };

        apps = pkgs.mkApps {
          dev = "uv run python-template";
        };

        packages = pkgs.mkPackages pkgs (pkgs: {
          default = pkgs.python314Packages.buildPythonPackage (finalAttrs: {
            pname = "python-template";
            version = "0.0.4";
            pyproject = true;

            src = pkgs.lib.fileset.toSource {
              root = ./.;
              fileset = pkgs.lib.fileset.unions [
                ./uv.lock
                ./pyproject.toml
                ./.python-version
                ./.github/README.md
                (pkgs.lib.fileset.fileFilter (file: file.hasExt "py") ./.)
              ];
            };

            build-system = with pkgs.python314Packages; [
              setuptools
              uv-build
            ];

            meta = {
              description = "python template";
              mainProgram = "python-template";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.all;
              homepage = "https://github.com/spotdemo4/python-template";
              changelog = "https://github.com/spotdemo4/python-template/releases/tag/v${finalAttrs.version}";
              downloadPage = "https://github.com/spotdemo4/python-template/releases/tag/v${finalAttrs.version}";
            };
          });
        });

        images = pkgs.mkImages pkgs (pkgs: {
          default = pkgs.mkImage self.packages.${system}.default {
            contents = with pkgs; [ dockerTools.caCertificates ];
          };
        });

        formatter = pkgs.nixfmt-tree;
        schemas = trev.schemas;
      }
    );
}
