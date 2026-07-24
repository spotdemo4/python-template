# python template

[![check](https://trev.zip/template/python/actions/workflows/check.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://trev.zip/template/python/actions?workflow=check.yaml)
[![vulnerable](https://trev.zip/template/python/actions/workflows/vulnerable.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://trev.zip/template/python/actions?workflow=vulnerable.yaml)
[![python](<https://img.shields.io/badge/dynamic/regex?url=https://trev.zip/template/python/raw/branch/main/.python-version&search=(.*)&logo=python&logoColor=%23bac2de&label=version&labelColor=%23313244&color=%23306998>)](https://www.python.org/downloads/)

template for starting [python](https://www.python.org/) projects

part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## requirements

- [nix](https://nixos.org/)

## getting started

```sh
nix develop
./init.sh "Title" "Description"
```

### run

> [!IMPORTANT]
> when using a nix development shell do not use `uv run`
>
> `uv run` makes `uv` provision its own virtual environment
>
> all python scripts (including your own [entry points](https://peps.python.org/pep-0621/#entry-points)) are available in the nix development shell

run a python script

```sh
python-template
```

run the nix package

```sh
nix run
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

releases are automatically created for [significant](https://www.conventionalcommits.org/en/v1.1.0/#summary) changes

## use

### uv

```sh
uvx python-template \
  --index https://trev.zip/api/packages/template/pypi
```

### pip

```sh
pip install python-template \
    --index-url https://trev.zip/api/packages/template/pypi/simple
```

### docker

```sh
docker run trev.zip/template/python:latest
```

### nix

```sh
nix run git+https://trev.zip/template/python.git
```

### download

https://trev.zip/template/python/releases
