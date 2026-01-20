---
name: moonbit-docs
description: MoonBit documentation assistant. Provides access to MoonBit language documentation and guides.
---

# MoonBit Documentation Skill

This skill provides access to MoonBit language documentation.

## Directory Structure

```
references/
├── errors/          # Compiler error codes (E0xxx, E3xxx, E4xxx) - 219 files
├── language/        # Language features (ffi, derive, error-handling, etc.)
├── getting-started/ # Introduction, tour, tutorial
├── tooling/         # Commands, configuration, tests, VSCode, MoonBit Pilot
├── packages/        # Module and package management
└── examples/        # Tutorial series (gmachine, myers-diff, segment-tree)
```

## Usage

1. Search or read files in `references/` subdirectories
2. Run `scripts/cli.ts search <query>` to search documentation
3. Each file has frontmatter with `source_url` and `fetched_at`
4. Always cite the source URL in responses

## Search Tool

```bash
deno run -A scripts/cli.ts search "<query>"
deno run -A scripts/cli.ts search "<query>" --json
deno run -A scripts/cli.ts search "<query>" -n 5
```

## Response Format

When answering questions, include:

```
[Answer based on documentation]

**Source:** [source_url]
**Fetched:** [fetched_at]
```
