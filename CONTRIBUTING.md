# contributing

## requirements

- [nix](https://nixos.org/)

## getting started

```sh
nix develop
```

### run

> [!IMPORTANT]
> when using a nix development shell do not use `uv run`, `uv run` makes `uv` provision its own virtual environment
>
> all python scripts (including your own [entry points](https://peps.python.org/pep-0621/#entry-points)) are available in the nix development shell

run a python script

```sh
python-template
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

releases are automatically created for [significant](https://www.conventionalcommits.org/en/v1.4.1/#summary) changes
