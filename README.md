# python template

[![check](https://img.shields.io/github/actions/workflow/status/spotdemo4/python-template/check.yaml?branch=main&logo=github&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://github.com/spotdemo4/python-template/actions/workflows/check.yaml/)
[![vulnerable](https://img.shields.io/github/actions/workflow/status/spotdemo4/python-template/vulnerable.yaml?branch=main&logo=github&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://github.com/spotdemo4/python-template/actions/workflows/vulnerable.yaml)
[![python](<https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Fraw.githubusercontent.com%2Fspotdemo4%2Fpython-template%2Frefs%2Fheads%2Fmain%2F.python-version&search=(.*)&logo=python&logoColor=%23bac2de&label=version&labelColor=%23313244&color=%23306998>)](https://www.python.org/downloads/)
[![pypi](https://img.shields.io/pypi/v/spotdemo4.python-template?logo=pypi&logoColor=%23bac2de&labelColor=%23313244&color=%23306998&label=PyPI)](https://pypi.org/project/spotdemo4.python-template/)

template for starting [Python](https://www.python.org/) projects

part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## requirements

- [nix](https://nixos.org/)

## getting started

```sh
nix develop
```

### run

```sh
nix run #dev
```

### format

```sh
nix fmt
```

### check

```sh
nix flake check
```

### build

```sh
nix build
```

### release

```sh
bumper
```

releases are automatically created for [significant](https://www.conventionalcommits.org/en/v1.0.0/#summary) changes

## use

### uv

```sh
uvx spotdemo4.python-template
```

### docker

```sh
docker run ghcr.io/spotdemo4/python-template:0.3.0
```

### nix

```sh
nix run github:spotdemo4/python-template
```

### download

https://trev.zip/template/python/releases
