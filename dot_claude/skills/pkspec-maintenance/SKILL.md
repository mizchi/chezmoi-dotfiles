---
name: pkspec-maintenance
description: Use when working on github.com/mizchi/pkspec, especially release readiness, version bumps, GitHub Actions/Nix release checks, adapter DSL work, or the experimental Playwright/Vitest coverage presets. Covers the repo's spec gates, pkfire release flow, pkl CLI dependency gotchas, and what is intentionally still experimental.
---

# pkspec Maintenance

## Context

`pkspec` is a Go CLI with Pkl schemas, a Nix package, a composite GitHub
Action, and experimental adapter coverage work. Prefer repo-local
contracts over ad hoc judgment: `SPEC.pkl`, examples, Pkl tests, Go
tests, and GitHub Actions are the release gate.

## Release Readiness

Use this checklist before releasing:

```sh
git status --short --branch
go run ./cmd/pkspec spec --next SPEC.pkl examples/*/Test.pkl
go run ./cmd/pkspec spec --orphans SPEC.pkl examples/*/Test.pkl
gh issue list --repo mizchi/pkspec --state open --limit 50
gh run list --repo mizchi/pkspec --branch main --limit 8
```

`spec --next` must report no outstanding implementation work.
Open issues are not automatically blockers. If the only open issue is
native adapter shim work, treat it as future enhancement unless the
user says otherwise.

Run the local release gate:

```sh
pkf run release-check
pkl test pkl/Test.test.pkl pkl/QuickCheck.test.pkl pkl/Adapter.test.pkl
go run ./cmd/pkspec spec --check --strict SPEC.pkl examples/*/Test.pkl
node --test experiments/adapter-coverage-presets/scripts/playwright-coverage.test.mjs
```

## Version Bump

For a patch release, bump all fixed examples and release variables:

- `flake.nix`: `version = "X.Y.Z"`
- `Taskfile.pkl`: `local releaseVersion = "X.Y.Z"`
- `action.yml`: example version strings in the `version` input docs
- `README.md`: install/action/tag examples

Confirm no old version remains:

```sh
OLD_VERSION=0.1.5
rg -n "${OLD_VERSION}|v${OLD_VERSION}" . --glob '!**/.git/**'
```

Use the actual prior version. Then commit:

```sh
git add README.md Taskfile.pkl action.yml flake.nix
git commit -m "Bump release version to X.Y.Z"
```

## Tag And Publish

Use pkfire, not hand-written tag commands:

```sh
pkf run tag --version=X.Y.Z
```

This reruns `release-check`, checks the tree is clean, creates annotated
tag `vX.Y.Z`, pushes `main`, and pushes the tag. The Release workflow
then validates Nix on Linux/macOS and publishes the GitHub Release.

Watch the relevant runs:

```sh
gh run list --repo mizchi/pkspec --limit 10
gh run watch <release-run-id> --repo mizchi/pkspec --exit-status
gh release view vX.Y.Z --repo mizchi/pkspec
gh release list --repo mizchi/pkspec --limit 3
```

The main `Action` workflow may install the previous `latest` while the
release is still in progress; that annotation is not a failure if the
job succeeds.

## Adapter And Coverage Notes

Adapter definitions live in Pkl data, not a Go registry:

- core schema: `pkl/Adapter.pkl`
- built-ins: `pkl/adapters/*.pkl`
- runtime: `pkspec adapter -f Adapter.pkl`
- smoke fixture: `examples/adapter-protocol-smoke`

Native commands such as `pkspec-adapter-vitest`,
`pkspec-adapter-playwright`, `pkspec-adapter-node-test`,
`pkspec-adapter-go-test`, and `pkspec-adapter-moon-test` are tracked as
future shim work. Do not silently promote experimental shims to core.

Coverage preset experiments belong under:

```sh
experiments/adapter-coverage-presets/
```

The experimental Playwright coverage shim has fixture tests that do not
require Playwright installation:

```sh
node --test experiments/adapter-coverage-presets/scripts/playwright-coverage.test.mjs
node experiments/adapter-coverage-presets/scripts/pkspec-adapter-playwright.mjs coverage \
  --from-json experiments/adapter-coverage-presets/fixtures/playwright-coverage.json \
  --coverage-kind js \
  --coverage-kind css
```

## CI Gotcha: pkl CLI

`pkl-go` shells out to `pkl`. Generic Go CI does not install the Pkl CLI,
so adapter integration tests must skip when `pkl` is absent. Nix package
checks intentionally add `pklNative` through `nativeCheckInputs`, so the
same tests run for the Nix package. Preserve both sides:

- `cmd/pkspec/adapter_cmd_test.go` skips if `exec.LookPath("pkl")` fails.
- `flake.nix` has `nativeCheckInputs = [ pklNative ];`.
- the Nix smoke path runs `pkspec adapter -f examples/adapter-protocol-smoke/Adapter.pkl`.
