---
title: "Module Configuration — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/toolchain/moon/module"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/toolchain/moon/module.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/toolchain/moon/module.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Ftoolchain/moon/module.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/toolchain/moon/module.md "Download source file")
* .pdf

# Module Configuration

## Contents

# Module Configuration[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#module-configuration "Link to this heading")

moon uses the `moon.mod.json` file to identify and describe a module.

Hint

For the most up-to-date and complete JSON schema, please check [moon's repository](https://github.com/moonbitlang/moon/blob/main/crates/moonbuild/template/mod.schema.json).

## Name[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#name "Link to this heading")

The `name` field is used to specify the name of the module, and it is required.

```
{
  "name": "example"
  // ...
}
```

The module name can contain letters, numbers, `_`, `-`, and `/`.

For modules published to [mooncakes.io](https://mooncakes.io), the module name must begin with the username. For example:

```
{
  "name": "moonbitlang/core"
  // ...
}
```

## Version[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#version "Link to this heading")

The `version` field is used to specify the version of the module.

This field is optional. For modules published to [mooncakes.io](https://mooncakes.io), the version number must follow the [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) specification.

```
{
  "name": "example",
  "version": "0.1.0"
  // ...
}
```

## Dependency Management[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#dependency-management "Link to this heading")

The `deps` field is used to specify the dependencies of the module.

It is automatically managed by commands like `moon add` and `moon remove`.

```
{
  "name": "username/hello",
  "deps": {
    "moonbitlang/x": "0.4.6"
  }
}
```

You may also specify a local dependency, such as:

```
{
  "name": "username/hello",
  "deps": {
    "username/other": {
      "path": "../other"
    }
  }
}
```

## Meta Information[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#meta-information "Link to this heading")

### README[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#readme "Link to this heading")

The `readme` field is used to specify the path to the module's README file.

### Repository[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#repository "Link to this heading")

The `repository` field is used to specify the URL of the module's repository.

### License[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#license "Link to this heading")

The `license` field is used to specify the license of the module. The license type must comply with the [SPDX License List](https://spdx.org/licenses/).

```
{
  "license": "MIT"
}
```

### Keywords[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#keywords "Link to this heading")

The `keywords` field is used to specify the keywords for the module.

```
{
  "keywords": ["example", "test"]
}
```

### Description[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#description "Link to this heading")

The `description` field is used to specify the description of the module.

```
{
  "description": "This is a description of the module."
}
```

## Include and Exclude[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#include-and-exclude "Link to this heading")

The `include` and `exclude` fields are used to include or exclude specific directories or files during publishing process.

It follows the gitignore syntax, and include follows the exclude.
For example, the following configuration will include the `build/assets`
but exclude anything else in the `build` directory.

```
{
  "exclude": ["build"],
  "include": ["build/assets"]
}
```

You may use [`moon package --list`](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-package) to verify if the packaged result is expected.

## Preferred Target[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#preferred-target "Link to this heading")

The `preferred-target` field allows the `moon` and the language server to know which target
should be used as the default target, avoiding the necessity to write `--target`
when developing a project targeting other backends than Wasm GC.

```
{
  "preferred-target": "js"
}
```

## Source directory[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#source-directory "Link to this heading")

The `source` field is used to specify the source directory of the module.

It must be a subdirectory of the directory where the `moon.mod.json` file is located and must be a relative path.

When creating a module using the `moon new` command, a `src` directory will be automatically generated, and the default value of the `source` field will be `src`.

```
{
  "source": "src"
}
```

When the `source` field does not exist, or its value is `null` or an empty string `""`, it is equivalent to setting `"source": "."`. This means that the source directory is the same as the directory where the `moon.mod.json` file is located.

```
{
  "source": null
}
{
  "source": ""
}
{
  "source": "."
}
```

## Warning List[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#warning-list "Link to this heading")

This is used to disable specific preset compiler warning numbers.

For example, in the following configuration, `-2` disables the warning number 2 (Unused variable).

```
{
  "warn-list": "-2"
}
```

If multiple warnings need to be disabled, they can be directly connected and combined.

```
{
  "warn-list": "-2-4"
}
```

If it is necessary to activate certain warnings that were originally prohibited, use the plus sign.

```
{
  "warn-list": "+31"
}
```

You can use `moonc build-package -warn-help` to see the list of preset compiler warning numbers.

```
$ moonc -v
v0.1.20250606+a3f4966ca

$ moonc build-package -warn-help
Available warnings:
  1 Unused function.
  2 Unused variable.
  3 Unused type declaration.
  4 Unused abstract type.
  5 Unused type variable.
  6 Unused constructor.
  7 Unused field or constructor argument.
  8 Redundant modifier.
  9 Unused function declaration.
 10 Struct never constructed.
 11 Partial pattern matching.
 12 Unreachable code.
 13 Unresolved type variable.
 14 Lowercase type name.
 15 Unused mutability.
 16 Parser inconsistency.
 18 Useless loop expression.
 19 Top-level declaration is not left aligned.
 20 Invalid pragma
 21 Some arguments of constructor are omitted in pattern.
 22 Ambiguous block.
 23 Useless try expression.
 24 Useless error type.
 26 Useless catch all.
 27 Deprecated syntax.
 28 Todo
 29 Unused package.
 30 Empty package alias.
 31 Optional argument never supplied.
 32 Default value of optional argument never used.
 33 Unused import value
 35 Reserved keyword.
 36 Loop label shadows another label.
 37 Unused loop label.
 38 Useless guard.
 39 Duplicated method.
 40 Call a qualified method using regular call syntax.
 41 Closed map pattern.
 42 Invalid attribute.
 43 Unused attribute.
 44 Invalid inline-wasm.
 46 Useless `..` in pattern
 47 Invalid mbti file
 48 Trait method with default implementation not marked with `= _`
 49 Unused pub definition because it does not exist in mbti file.
  A all warnings
```

## Alert List[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#alert-list "Link to this heading")

Disable user preset alerts.

```
{
  "alert-list": "-alert_1-alert_2"
}
```

## Scripts[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#scripts "Link to this heading")

The `scripts` field is used to define custom scripts associated with the module.

### postadd script[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#postadd-script "Link to this heading")

The `postadd` script runs automatically after the module has been added.
When executed, the script's current working directory (cwd) is set to the
directory where the `moon.mod.json` file resides.

```
{
  "scripts": {
    "postadd": "python3 build.py"
  }
}
```

### [Experimental] Pre-build config script[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#experimental-pre-build-config-script "Link to this heading")

Warning

This feature is extremely experimental, and its API may change at any time.
This documentation reflects the implementation as of 2025-06-03.

Important

Using this feature may execute arbitrary code in your computer.
Please use with caution and only with trusted dependencies.

The pre-build config script is added in order to aid native target programming.
To use such script, add your script in your `moon.mod.json`:

```
{
  "--moonbit-unstable-prebuild": "<path/to/build-script>"
}
```

The path is a relative path from the root of the project. The script may either
be a JavaScript script (with extension `.js`, `.cjs`, `.mjs`) executed with
`node`, or a Python script (with extension `.py`) executed with `python3` or
`python`.

#### Input[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#input "Link to this heading")

The script will be provided with a JSON with the structure of
`BuildScriptEnvironment` from standard input stream (stdin):

```
/** Represents the environment a build script receives */
interface BuildScriptEnvironment {
  env: Record<string, string>
  paths: Paths
}

interface BuildInfo {
  /** The target info for the build script currently being run. */
  host: TargetInfo
  /** The target info for the module being built. */
  target: TargetInfo
}

interface TargetInfo {
  /** The actual backend we're using, e.g. `wasm32`, `wasmgc`, `js`, `c`, `llvm` */
  kind: string // TargetBackend
}
```

#### Output[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#output "Link to this heading")

The script is expected to print a JSON string in its standard output stream
(stdout) with the structure of `BuildScriptOutput`:

```
interface BuildScriptOutput {
  /** Build variables */
  vars?: Record<string, string>
  /** Configurations to linking */
  link_configs?: LinkConfig[]
}

interface LinkConfig {
  /** The name of the package to configure */
  package: string

  /** Link flags that needs to be propagated to dependents
   *
   * Reference: `cargo::rustc-link-arg=FLAG` */
  link_flags?: string

  /** Libraries that need linking, propagated to dependents
   *
   * Reference: `cargo::rustc-link-lib=LIB` */
  link_libs?: string[]

  /** Paths that needs to be searched during linking, propagated to dependents
   *
   * Reference: `cargo::rustc-link-search=[KIND=]PATH` */
  link_search_paths?: string[]
}
```

#### Build variables[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#build-variables "Link to this heading")

You may use the variables emitted in the `vars` fields in the native linking
arguments in `moon.pkg.json` as `${build.<var_name>}`.

For example, if your build script outputs:

```
{ "vars": { "CC": "gcc" } }
```

and your `moon.pkg.json` is structured like:

```
{
  "link": {
    "native": {
      "cc": "${build.CC}"
    }
  }
}
```

It will be transformed into

```
{
  "link": {
    "native": {
      "cc": "gcc"
    }
  }
}
```

Contents
