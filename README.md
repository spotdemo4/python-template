# python template

[![check](https://trev.zip/template/python/actions/workflows/check.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://trev.zip/template/python/actions?workflow=check.yaml)
[![vulnerable](https://trev.zip/template/python/actions/workflows/vulnerable.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://trev.zip/template/python/actions?workflow=vulnerable.yaml)
[![nixpkgs](https://nix-shield.trev.zip/?url=https://trev.zip/template/python/raw/branch/main/flake.lock&input=nixpkgs&logoColor=%23bac2de&labelColor=%23313244&color=%235277C3)](https://nixos.org/)
[![python](<https://img.shields.io/badge/dynamic/regex?url=https://trev.zip/template/python/raw/branch/main/.python-version&search=(.*)&logo=python&logoColor=%23bac2de&label=version&labelColor=%23313244&color=%23306998>)](https://www.python.org/downloads/)

template for starting [python](https://www.python.org/) projects

to initialize a new project, run:

```sh
./init.sh "Title" "Description"
```

part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## using

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

## contributing

see [CONTRIBUTING.md](CONTRIBUTING.md) for requirements and getting started
