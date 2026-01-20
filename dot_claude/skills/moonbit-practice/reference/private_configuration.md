---
title: "MoonBit Configuration Reference"
---

# MoonBit Configuration Reference

## File Structure

```
my-project/
├── moon.mod.json    # Module configuration (project-wide)
└── src/
    ├── moon.pkg       # Package configuration (new format)
    └── main.mbt
```

## Migrating from moon.pkg.json to moon.pkg

`moon.pkg.json` is being migrated to the custom syntax `moon.pkg`. Convert with:

```bash
NEW_MOON_PKG=1 moon fmt
```

This converts `moon.pkg.json` to `moon.pkg`.

## moon.pkg (New Format)

Compared to JSON: supports comments, trailing commas, and more concise syntax.

### Imports

```moonbit
// Basic import
import {
  "moonbitlang/async/io",
  "path/to/pkg" as @alias,
}

// Test imports
import "test" {
  "path/to/pkg5",
}

// White-box test imports
import "wbtest" {
  "path/to/pkg7",
}
```

### Options

```moonbit
options(
  "is-main": true,
  "bin-name": "name",
  link: { "native": { "cc": "gcc" } },
)
```

### Comparison with JSON

| Feature | JSON Format | moon.pkg Format |
|---------|-------------|-----------------|
| Comments | ❌ Not supported | ✅ Supported |
| Trailing comma | ❌ Not supported | ✅ Supported |
| Readability | Low (verbose) | High (concise) |

## moon.mod.json (Module Configuration)

### Required Fields

```json
{
  "name": "username/project-name",
  "version": "0.1.0"
}
```

### Dependencies

```json
{
  "deps": {
    "moonbitlang/x": "0.4.6",
    "username/other": { "path": "../other" }
  }
}
```

### Metadata

```json
{
  "license": "MIT",
  "repository": "https://github.com/...",
  "description": "...",
  "keywords": ["example", "test"]
}
```

### Source Directory

```json
{
  "source": "src"
}
```

### Target Specification

```json
{
  "preferred-target": "js"
}
```

### Warning Configuration

```json
{
  "warn-list": "-2-4",
  "alert-list": "-alert_1"
}
```

## moon.pkg.json (Package Configuration)

### Main Package

```json
{
  "is-main": true
}
```

### Dependencies

```json
{
  "import": [
    "moonbitlang/quickcheck",
    { "path": "moonbitlang/x/encoding", "alias": "lib" }
  ],
  "test-import": [...],
  "wbtest-import": [...]
}
```

### Conditional Compilation

```json
{
  "targets": {
    "only_js.mbt": ["js"],
    "only_wasm.mbt": ["wasm"],
    "not_js.mbt": ["not", "js"],
    "debug_only.mbt": ["debug"],
    "js_release.mbt": ["and", ["js"], ["release"]]
  }
}
```

Conditions: `wasm`, `wasm-gc`, `js`, `debug`, `release`
Operators: `and`, `or`, `not`

### Link Options

#### JS Backend

```json
{
  "link": {
    "js": {
      "exports": ["hello", "foo:bar"],
      "format": "esm"
    }
  }
}
```

format: `esm` (default), `cjs`, `iife`

#### Wasm Backend

```json
{
  "link": {
    "wasm-gc": {
      "exports": ["hello"],
      "use-js-builtin-string": true
    }
  }
}
```

### Pre-build

```json
{
  "pre-build": [
    {
      "input": "a.txt",
      "output": "a.mbt",
      "command": ":embed -i $input -o $output"
    }
  ]
}
```

`:embed` converts files to MoonBit source (`--text` or `--binary`)

## Warning Numbers

Common ones:
- `1` Unused function
- `2` Unused variable
- `11` Partial pattern matching
- `12` Unreachable code
- `27` Deprecated syntax

Check all: `moonc build-package -warn-help`

## References

- Module: https://docs.moonbitlang.com/en/stable/toolchain/moon/module
- Package: https://docs.moonbitlang.com/en/stable/toolchain/moon/package
