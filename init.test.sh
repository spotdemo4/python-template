#!/usr/bin/env bash
# The tests often single-quote text containing $
# shellcheck disable=SC2016

# Tests init.sh. The init flake check runs it from a copy of the template.

set -euo pipefail

# shellcheck source=init.sh
source ./init.sh

template=$PWD
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp/home XDG_CONFIG_HOME=$tmp/home/.config GIT_CONFIG_NOSYSTEM=1
mkdir "$HOME"

fail() {
  printf 'not ok: %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  local actual=$1 expected=$2 name=$3
  if [[ $actual != "$expected" ]]; then
    fail "$name: expected '$expected', got '$actual'"
  fi
}

# Runs a command that must fail with the expected output.
assert_fails() {
  local expected=$1 output
  shift
  if output=$("$@" 2>&1); then
    fail "$* succeeded"
  fi
  assert_eq "$output" "$expected" "$*"
}

assert_contains() {
  local file=$1 text
  shift
  for text in "$@"; do
    grep -qF -- "$text" "$file" || fail "$file does not contain '$text'"
  done
}

assert_lacks() {
  local file=$1 text
  shift
  for text in "$@"; do
    if grep -qF -- "$text" "$file"; then
      fail "$file contains '$text'"
    fi
  done
}

assert_missing() {
  local path
  for path in "$@"; do
    if [[ -e $path ]]; then
      fail "$path exists"
    fi
  done
}

test_parse_remote() {
  local url expected
  while read -r url expected; do
    parse_remote 'Origin URL' "$url"
    assert_eq "$remote_host $remote_repo_path $remote_web_url" "$expected" "parse_remote $url"
  done <<'EOF'
https://github.com/octo/hello.git github.com octo/hello https://github.com/octo/hello
http://user@git.example.com:3000/octo/hello git.example.com:3000 octo/hello http://git.example.com:3000/octo/hello
git@github.com:octo/hello.git github.com octo/hello https://github.com/octo/hello
ssh://git@git.example.com:2222/group/sub/hello.git git.example.com group/sub/hello https://git.example.com/group/sub/hello
EOF

  assert_fails 'Origin URL cannot contain a query string or fragment.' parse_remote 'Origin URL' 'https://github.com/octo/hello?tab=readme'
  assert_fails 'Unsupported repository URL.' parse_remote 'Repository URL' 'ftp://github.com/octo/hello'
  assert_fails 'Origin URL must identify an owner and repository.' parse_remote 'Origin URL' 'git@github.com:hello.git'
  assert_fails 'Origin URL contains unsupported host or path characters.' parse_remote 'Origin URL' 'https://github.com/octo/hello world'
}

test_slugify() {
  assert_eq "$(slugify 'Hello World')" hello-world 'slugify Hello World'
  assert_eq "$(slugify ' My_App 2! ')" my-app-2 'slugify My_App 2!'
  assert_fails 'Title must produce a package name beginning with a letter.' slugify '2048'
  assert_fails 'Title must produce a package name beginning with a letter.' slugify '!!!'
}

test_python_module() {
  assert_eq "$(python_module hello-world)" hello_world 'python_module hello-world'
  assert_eq "$(python_module match)" match 'python_module match'
  assert_fails 'Title must produce a Python module name that is not a keyword.' python_module class
  assert_fails 'Title must produce a Python module name that is not a keyword.' python_module async
}

test_nix_string() {
  assert_eq "$(nix_string 'Say "hi" to ${USER} \o/')" 'Say \"hi\" to \${USER} \\o/' nix_string
}

test_toml_string() {
  assert_eq "$(toml_string 'Say "hi" to ${USER} \o/')" 'Say \"hi\" to ${USER} \\o/' toml_string
}

# Creates the template's upstream repository, which init.sh fetches to find the
# template commit.
create_upstream() {
  git init --quiet "$tmp/upstream"
  cp -a "$template/." "$tmp/upstream"
  git -C "$tmp/upstream" add -A
  git -C "$tmp/upstream" commit --quiet --message 'feat: template'
  git config --global url."$tmp/upstream".insteadOf "$old_url"
  upstream_commit=$(git -C "$tmp/upstream" rev-parse HEAD)
}

# Copies the template into a new repository with an origin remote.
new_project() {
  local dir=$1 origin=$2
  git init --quiet "$dir"
  cp -a "$template/." "$dir"
  git -C "$dir" remote add origin "$origin"
}

# Checks what init.sh does for every project in the current directory.
assert_initialized() {
  local slug=$1 email=$2
  assert_missing init.sh init.test.sh template.schema.json
  assert_eq "$(git log --format='%an <%ae> %s')" "Test User <$email> chore: initialize project" 'commits'
  assert_eq "$(git status --porcelain --untracked-files=all)" '' 'worktree status'
  assert_eq "$(jq -r .commit .template.json)" "$upstream_commit" '.template.json commit'
  assert_eq "$(git grep -n -e python-template -e python_template -e 'python template' -e trev.zip/template -e template/python -e init.sh -e init.test.sh -- ':!.template.json' ':!AGENTS.md' || true)" '' 'template references'
  assert_contains pyproject.toml "name = \"$slug\"" "module-name = \"${slug//-/_}\"" 'version = "0.0.1"'
  assert_contains uv.lock "name = \"$slug\"" 'version = "0.0.1"'
  assert_contains LICENSE "Copyright (c) $(date +%Y) Test User"
}

test_application() (
  local project=$tmp/hello-world description='Says "hi" to ${USER} \o/'
  new_project "$project" git@github.com:octo/hello-world.git
  cd "$project"
  # "use this template" creates a new commit with the template's tree
  git add -A
  git commit --quiet --message 'Initial commit'
  # The build sandbox has no /usr/bin/env for the shebang
  printf '%s\n' n n https://git.example.com/octo/hello-world '' '' | bash ./init.sh 'Hello World' "$description"

  assert_initialized hello-world test@example.com
  assert_eq "$(jq -r .library .template.json)" null '.template.json library'
  assert_eq "$(git remote)" $'forgejo\norigin' remotes
  assert_eq "$(head -n 1 README.md)" '# Hello World' 'README title'
  assert_contains README.md "$description" \
    'uvx --from git+https://github.com/octo/hello-world.git hello-world' \
    'pip install git+https://github.com/octo/hello-world.git' \
    'docker run ghcr.io/octo/hello-world:latest' \
    'https://github.com/octo/hello-world/releases'
  assert_contains flake.nix \
    'description = "Says \"hi\" to \${USER} \\o/";' \
    'mainProgram = "hello-world";' \
    'pythonImportsCheck = [ "hello_world" ];' \
    'homepage = "https://github.com/octo/hello-world";' \
    'actions-gh = {' 'actions-fj = {' \
    'name = "Test User";' 'email = "test@example.com";'
  assert_lacks flake.nix "$old_maintainer"
  assert_contains pyproject.toml \
    'description = "Says \"hi\" to ${USER} \\o/"' \
    'authors = [{ name = "Test User", email = "test@example.com" }]' \
    '[project.scripts]' 'hello-world = "hello_world:main"'
  assert_contains .github/renovate.jsonc '"repositories": ["octo/hello-world"]'
  assert_contains .forgejo/renovate.jsonc \
    '"endpoint": "https://git.example.com/api/v1"' \
    '"repositories": ["octo/hello-world"]'
  [[ -f src/hello_world/__init__.py && -d .zed && -d .vscode ]] || fail 'application files are missing'
)

test_library() (
  local project=$tmp/hello-lib
  new_project "$project" https://git.example.com/octo/hello-lib.git
  cd "$project"
  # nix flake init leaves the template uncommitted and init.sh not executable
  chmod -x init.sh
  # The template's author keeps their maintainer entry
  git config user.email Me@Trev.xyz
  printf '%s\n' y y n n | bash init.sh 'Hello Lib' 'Says hello'

  assert_initialized hello-lib Me@Trev.xyz
  assert_eq "$(jq -r .library .template.json)" true '.template.json library'
  assert_contains flake.nix "maintainers = [ $old_maintainer ];"
  assert_eq "$(git remote)" origin remotes
  assert_missing src/python_template src/hello_lib/python_template .github .zed .vscode
  assert_contains README.md \
    'uv add hello-lib' \
    '--index https://git.example.com/api/packages/octo/pypi' \
    'pip install hello-lib' \
    '--extra-index-url https://git.example.com/api/packages/octo/pypi/simple' \
    'requires-python%20%3D%20%22(.*)%22'
  assert_lacks README.md uvx 'docker run' .python-version
  assert_lacks pyproject.toml '[project.scripts]' hello_lib:main
  assert_contains flake.nix 'inherit (project) version;' ./tests 'python -m unittest discover'
  assert_lacks flake.nix mainProgram downloadPage 'bin/hello-lib' 'images = {' 'appimages = {' 'actions-gh = {' 'renovate-gh = {'
  assert_contains .forgejo/workflows/release.yaml 'PACKAGES: packages.x86_64-linux.default'
  assert_lacks .forgejo/workflows/release.yaml CONTAINER_REGISTRY_PASSWORD images.x86_64-linux appimages.x86_64-linux
  assert_lacks CONTRIBUTING.md '### run'
  assert_contains src/hello_lib/__init__.py 'def hello(name: str) -> str:'
  [[ -f src/hello_lib/py.typed && -f tests/test_hello.py ]] || fail 'library files are missing'
  ruff check
  ruff format --check
  pyright --warnings
  PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=src python -m unittest discover --start-directory tests
)

test_library_github() (
  local project=$tmp/hello-github
  new_project "$project" git@github.com:octo/hello-github.git
  cd "$project"
  chmod -x init.sh
  printf '%s\n' y y n n | bash init.sh 'Hello GitHub' 'Says hello'

  assert_initialized hello-github test@example.com
  assert_missing .forgejo
  assert_contains README.md $'```sh\nuv add hello-github\n```' $'```sh\npip install hello-github\n```'
  assert_contains .github/workflows/release.yaml 'PYPI_TRUSTED_PUBLISHING: "true"' 'PACKAGES: packages.x86_64-linux.default'
  assert_lacks .github/workflows/release.yaml 'packages: write' images.x86_64-linux appimages.x86_64-linux
)

test_rollback() (
  local project=$tmp/rollback head
  new_project "$project" git@github.com:octo/rollback.git
  cd "$project"
  git add -A
  git commit --quiet --message 'Initial commit'
  head=$(git rev-parse HEAD)

  touch untracked
  assert_fails 'Commit or discard all existing worktree changes before running the initializer.' \
    bash ./init.sh Rollback Rollback </dev/null
  rm untracked

  # The Forgejo URL is read after the template has been changed
  assert_fails 'Unsupported repository URL.' \
    bash ./init.sh Rollback Rollback < <(printf '%s\n' n n ftp://git.example.com/octo/rollback)
  assert_eq "$(git rev-parse HEAD)" "$head" HEAD
  assert_eq "$(git status --porcelain --untracked-files=all)" '' 'worktree status'
  assert_missing src/rollback "$tmp"/.rollback.git-*
)

git config --global user.name 'Test User'
git config --global user.email test@example.com
git config --global init.defaultBranch main

# nix fmt can't evaluate the flake in the build sandbox, so run its formatter
mkdir "$tmp/bin"
printf '#!%s\n[[ $* == fmt ]] && TREEFMT_TREE_ROOT=$PWD exec treefmt\nexit 1\n' "$BASH" >"$tmp/bin/nix"
chmod +x "$tmp/bin/nix"
PATH=$tmp/bin:$PATH

create_upstream
for test in test_parse_remote test_slugify test_python_module test_nix_string test_toml_string test_application test_library test_library_github test_rollback; do
  "$test"
  printf 'ok: %s\n' "$test"
done
