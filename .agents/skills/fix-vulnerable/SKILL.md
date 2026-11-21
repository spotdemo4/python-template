---
name: fix-vulnerable
description: Fixes failures reported by the vulnerable workflow, which runs pysentry, flake-checker and zizmor. Use when the vulnerable workflow fails, or when asked about a Python advisory (GHSA, PYSEC, CVE), an outdated nixpkgs input or a zizmor finding.
---

# Fix Vulnerable

The `vulnerable` workflow runs weekly in each forge directory (`.github`, `.gitea`, `.forgejo`, `.tangled`) that exists, with a job for each tool. Tangled runs each tool as its own workflow (`vulnerable-nix`, `vulnerable-python`) and skips zizmor, which only audits Actions workflows. Read the failed job's log to find which tool failed and why, then reproduce it locally in the `vulnerable` dev shell:

```sh
nix develop .#vulnerable -c pysentry
nix develop .#vulnerable -c flake-checker -f
nix develop .#vulnerable -c zizmor .github/workflows
```

## pysentry

pysentry audits the packages pinned in `uv.lock` against the PyPA, PyPI and OSV advisory databases, and exits non-zero when a finding is medium severity or higher (or has an unknown severity). Without a lock file it falls back to resolving `pyproject.toml`.

Renovate opens automerging fix PRs for vulnerable direct dependencies, so check for an open Renovate PR first. A failure without one is usually a transitive dependency.

1. Update the vulnerable package within its current requirements with `uv lock --upgrade-package <package>`, or `--upgrade-package <package>==<version>` to pick the patched version.
2. If a dependent's version requirement rules out the patched version, update the direct dependency that pulls it in, in `pyproject.toml`, then run `uv lock --upgrade-package <dependency>`. Find it with `uv tree --invert --package <package>`.
3. Only when no patched version exists, or the vulnerable code is unreachable, ignore the advisory with a comment explaining why, and tell the user. Use `ids` to ignore it always, or `while_no_fix` to ignore it only until a fix is released. Entries match an advisory's ID and its aliases. In `.pysentry.toml`:

   ```toml
   version = 1
   
   [ignore]
   ids = [
     "GHSA-0000-0000-0000", # reason
   ]
   ```

   Or in `pyproject.toml`, under `[tool.pysentry.ignore]` with `version = 1` in `[tool.pysentry]`. `.pysentry.toml` takes precedence when both exist. Check the file with `nix develop .#vulnerable -c pysentry config validate`.

`uv` isn't in the `vulnerable` dev shell, so run the `uv` commands in the default dev shell. The Nix build takes its dependencies from nixpkgs, not `uv.lock`, so fixing the lock file doesn't change the built package. If the vulnerable version also comes from nixpkgs, run `nix flake update nixpkgs`.

Maintenance warnings (archived, deprecated or unmaintained packages) don't fail the job.

## flake-checker

flake-checker fails when a nixpkgs input is outdated (over 30 days old), not owned by `NixOS`, or tracks an unsupported branch. Renovate only updates Nix inputs during its weekly lock file maintenance, which automerges.

1. Check for an open Renovate lock file maintenance PR. If one exists, its checks are probably failing, so fix the failure on that PR's branch instead of opening a competing one.
2. Otherwise run `nix flake update`, then fix anything the update breaks.
3. For an owner or branch failure, change the input's URL in `flake.nix` to a supported `NixOS/nixpkgs` branch.

## zizmor

zizmor audits the workflows for security issues. CI runs its online audits with a GitHub token. Locally, set `GH_TOKEN` to enable them, for example with `GH_TOKEN=$(gh auth token)`, or they're skipped.

1. Fix the finding in every forge directory that has the workflow, not only the one that failed. The forges' workflows differ: GitHub and Gitea set `permissions`, while Forgejo doesn't support them and uses `enable-openid-connect`. Adapt the fix to each forge rather than copying it.
2. Pinned action updates (`unpinned-uses`, known vulnerable versions) are Renovate's job, so check for an open Renovate PR first.
3. Only when a finding doesn't apply to a forge, ignore it with an inline `# zizmor: ignore[<audit>]` comment on the flagged line, as the Forgejo workflows do for `excessive-permissions`.

## Finish

Run `nix flake check`, and confirm each tool that failed now passes locally.
