Release a MoonBit CLI project. Argument: `minor` or `patch` (default: `patch`).

## Steps

1. Read `moon.mod.json` and extract the current `"version"` field (semver: `MAJOR.MINOR.PATCH`).
2. Based on the argument `$ARGUMENTS`:
   - `minor` → bump MINOR, reset PATCH to 0 (e.g. `0.25.0` → `0.26.0`)
   - `patch` (or empty/default) → bump PATCH (e.g. `0.25.0` → `0.25.1`)
3. Update `moon.mod.json` with the new version string.
4. Run `just release-check` to verify the build and tests pass. If it fails, stop and report.
5. Git commit `moon.mod.json` with message: `chore: bump version to <NEW_VERSION>`
6. Create git tag `v<NEW_VERSION>`.
7. Push commits and tag: `git push origin <CURRENT_BRANCH> --tags`
8. Run `moon publish` to publish to mooncakes registry.
9. Report the completed version bump and published version.
