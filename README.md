# python template

[![check](https://img.shields.io/github/actions/workflow/status/spotdemo4/python-template/check.yaml?branch=main&logo=github&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://github.com/spotdemo4/python-template/actions/workflows/check.yaml/)
[![vulnerable](https://img.shields.io/github/actions/workflow/status/spotdemo4/python-template/vulnerable.yaml?branch=main&logo=github&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://github.com/spotdemo4/python-template/actions/workflows/vulnerable.yaml)
[![python](<https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Fraw.githubusercontent.com%2Fspotdemo4%2Fpython-template%2Frefs%2Fheads%2Fmain%2F.python-version&search=(.*)&logo=python&logoColor=%23bac2de&label=version&labelColor=%23313244&color=%23306998>)](https://www.python.org/downloads/)
[![flakehub](https://img.shields.io/endpoint?url=https://flakehub.com/f/spotdemo4/python-template/badge&labelColor=%23313244)](https://flakehub.com/flake/spotdemo4/python-template)
[![pypi](https://img.shields.io/pypi/v/spotdemo4.python-template?logo=pypi&logoColor=%23bac2de&labelColor=%23313244&color=%23306998&label=PyPI)](https://pypi.org/project/spotdemo4.python-template/)

template for starting [Python](https://www.python.org/) projects

part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## requirements

- [nix](https://nixos.org/)

## getting started

```elm
nix develop
```

### run

```elm
nix run #dev
```

### format

```elm
nix fmt
```

### check

```elm
nix flake check
```

### build

```elm
nix build
```

### release

```elm
bumper "README.md"
```

releases are automatically created for [significant](https://www.conventionalcommits.org/en/v1.0.0/#summary) changes

## use

### download

| Architecture | Download                                                                                                                                           |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| amd64        | [python-template_0.3.0_amd64.AppImage](https://github.com/spotdemo4/python-template/releases/download/v0.3.0/python-template_0.3.0_amd64.AppImage) |
| arm64        | [python-template_0.3.0_arm64.AppImage](https://github.com/spotdemo4/python-template/releases/download/v0.3.0/python-template_0.3.0_arm64.AppImage) |
| arm          | [python-template_0.3.0_arm.AppImage](https://github.com/spotdemo4/python-template/releases/download/v0.3.0/python-template_0.3.0_arm.AppImage)     |

### uv

```elm
uvx spotdemo4.python-template
```

### docker

```elm
docker run ghcr.io/spotdemo4/python-template:0.3.0
```

### nix

```elm
nix run github:spotdemo4/python-template
```
