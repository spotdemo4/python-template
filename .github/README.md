# python template

[![check](https://img.shields.io/github/actions/workflow/status/spotdemo4/node-template/check.yaml?branch=main&logo=github&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://github.com/spotdemo4/node-template/actions/workflows/check.yaml/)
[![vulnerable](https://img.shields.io/github/actions/workflow/status/spotdemo4/node-template/vulnerable.yaml?branch=main&logo=github&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://github.com/spotdemo4/node-template/actions/workflows/vulnerable.yaml)
[![nix](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fspotdemo4%2Fnode-template%2Frefs%2Fheads%2Fmain%2Fflake.lock&query=%24.nodes.nixpkgs.original.ref&logo=nixos&logoColor=%23bac2de&label=channel&labelColor=%23313244&color=%234d6fb7)](https://nixos.org/)

Template for starting [Python](https://www.python.org/) projects

Part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## Requirements

- [nix](https://nixos.org/)
- [direnv](https://direnv.net/) (optional)

## Getting started

Initialize direnv:

```elm
ln -s .envrc.project .envrc &&
direnv allow
```

or manually enter the development environment:

```elm
nix develop
```

then install dependencies:

```elm
npm i
```

### Run

```elm
nix run #dev
```

### Build

```elm
nix build
```

### Check

```elm
nix flake check
```

### Release

Releases are automatically created for [significant](https://www.conventionalcommits.org/en/v1.0.0/#summary) changes.

To manually create a version bump:

```elm
bumper action.yaml .github/README.md
```

## Use

### Download

| OS      | Architecture | Download                                                                                                                                           |
| ------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Linux   | amd64        | [node-template_0.6.0_linux_amd64.xz](https://github.com/spotdemo4/node-template/releases/download/v0.6.0/node-template_0.6.0_linux_amd64.xz)       |
| Linux   | arm64        | [node-template_0.6.0_linux_arm64.xz](https://github.com/spotdemo4/node-template/releases/download/v0.6.0/node-template_0.6.0_linux_arm64.xz)       |
| MacOS   | arm64        | [node-template_0.6.0_darwin_arm64.xz](https://github.com/spotdemo4/node-template/releases/download/v0.6.0/node-template_0.6.0_darwin_arm64.xz)     |
| Windows | amd64        | [node-template_0.6.0_windows_amd64.zip](https://github.com/spotdemo4/node-template/releases/download/v0.6.0/node-template_0.6.0_windows_amd64.zip) |

### Docker

```elm
docker run ghcr.io/spotdemo4/python-template:0.0.1
```

### Action

```yaml
- name: python template
  uses: spotdemo4/python-template@v0.0.1
```

### Nix

```elm
nix run github:spotdemo4/python-template
```
