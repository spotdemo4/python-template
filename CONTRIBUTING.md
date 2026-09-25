# contributing

## requirements

- [nix](https://nixos.org/)

## getting started

```sh
nix develop
```

with [direnv](https://direnv.net/):

```sh
ln -s .envrc.project .envrc
direnv allow
```

### run

```sh
nix run
```

with [python](https://www.python.org/):

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

with [ruff](https://docs.astral.sh/ruff/):

```sh
ruff format .
```

### check

```sh
nix flake check
```

with [ruff](https://docs.astral.sh/ruff/) and [basedpyright](https://docs.basedpyright.com/):

```sh
ruff check
basedpyright
```

### build

```sh
nix build
```

with [uv](https://docs.astral.sh/uv/):

```sh
uv build
```

### release

with [bumper](https://trev.zip/llc/bumper):

```sh
bumper
```

releases are automatically created for [significant](https://www.conventionalcommits.org/en/v1.4.1/#summary) changes
