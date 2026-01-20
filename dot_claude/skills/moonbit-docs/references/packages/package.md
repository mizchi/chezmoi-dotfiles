---
title: "Package Configuration — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/toolchain/moon/package"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/toolchain/moon/package.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/toolchain/moon/package.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Ftoolchain/moon/package.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/toolchain/moon/package.md "Download source file")
* .pdf

# Package Configuration

## Contents

# Package Configuration[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#package-configuration "Link to this heading")

moon uses the `moon.pkg.json` file to identify and describe a package. For full JSON schema, please check [moon's repository](https://github.com/moonbitlang/moon/blob/main/crates/moonbuild/template/pkg.schema.json).

## Name[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#name "Link to this heading")

The package name is not configurable; it is determined by the directory name of the package.

## is-main[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#is-main "Link to this heading")

The `is-main` field is used to specify whether a package needs to be linked into an executable file.

The output of the linking process depends on the backend. When this field is set to `true`:

* For the Wasm and `wasm-gc` backends, a standalone WebAssembly module will be generated.
* For the `js` backend, a standalone JavaScript file will be generated.

## Importing dependencies[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#importing-dependencies "Link to this heading")

### import[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#import "Link to this heading")

The `import` field is used to specify other packages that a package depends on.

For example, the following imports `moonbitlang/quickcheck` and `moonbitlang/x/encoding`,
aliasing the latter to `lib` and importing the function `encode` from the latter.
User can write `@lib.encode` instead of `encode`.

```
{
  "import": [
    "moonbitlang/quickcheck",
    { "path" : "moonbitlang/x/encoding", "alias": "lib", "value": ["encode"] }
  ]
}
```

### test-import[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#test-import "Link to this heading")

The `test-import` field is used to specify other packages that the black-box test package of this package depends on,
with the same format as `import`.

The `test-import-all` field is used to specify whether all public definitions from the package being tested should be imported (`true`) by default.

### wbtest-import[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#wbtest-import "Link to this heading")

The `wbtest-import` field is used to specify other packages that the white-box test package of this package depends on,
with the same format as `import`.

## Conditional Compilation[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#conditional-compilation "Link to this heading")

The smallest unit of conditional compilation is a file.

In a conditional compilation expression, three logical operators are supported: `and`, `or`, and `not`, where the `or` operator can be omitted.

For example, `["or", "wasm", "wasm-gc"]` can be simplified to `["wasm", "wasm-gc"]`.

Conditions in the expression can be categorized into backends and optimization levels:

* **Backend conditions**: `"wasm"`, `"wasm-gc"`, and `"js"`
* **Optimization level conditions**: `"debug"` and `"release"`

Conditional expressions support nesting.

If a file is not listed in `"targets"`, it will be compiled under all conditions by default.

Example:

```
{
  "targets": {
    "only_js.mbt": ["js"],
    "only_wasm.mbt": ["wasm"],
    "only_wasm_gc.mbt": ["wasm-gc"],
    "all_wasm.mbt": ["wasm", "wasm-gc"],
    "not_js.mbt": ["not", "js"],
    "only_debug.mbt": ["debug"],
    "js_and_release.mbt": ["and", ["js"], ["release"]],
    "js_only_test.mbt": ["js"],
    "js_or_wasm.mbt": ["js", "wasm"],
    "wasm_release_or_js_debug.mbt": ["or", ["and", "wasm", "release"], ["and", "js", "debug"]]
  }
}
```

## Link Options[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#link-options "Link to this heading")

By default, moon only links packages where `is-main` is set to `true`. If you need to link other packages, you can specify this with the `link` option.

The `link` option is used to specify link options, and its value can be either a boolean or an object.

* When the `link` value is `true`, it indicates that the package should be linked. The output will vary depending on the backend specified during the build.

  ```
  {
    "link": true
  }
  ```
* When the `link` value is an object, it indicates that the package should be linked, and you can specify link options. For detailed configuration, please refer to the subpage for the corresponding backend.

### Wasm Backend Link Options[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#wasm-backend-link-options "Link to this heading")

#### Common Options[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#common-options "Link to this heading")

* The `exports` option is used to specify the function names exported by the Wasm backend.

  For example, in the following configuration, the `hello` function from the current package is exported as the `hello` function in the Wasm module, and the `foo` function is exported as the `bar` function in the Wasm module. In the Wasm host, the `hello` and `bar` functions can be called to invoke the `hello` and `foo` functions from the current package.

  ```
  {
    "link": {
      "wasm": {
        "exports": [
          "hello",
          "foo:bar"
        ]
      },
      "wasm-gc": {
        "exports": [
          "hello",
          "foo:bar"
        ]
      }
    }
  }
  ```
* The `import-memory` option is used to specify the linear memory imported by the Wasm module.

  For example, the following configuration specifies that the linear memory imported by the Wasm module is the `memory` variable from the `env` module.

  ```
  {
    "link": {
      "wasm": {
        "import-memory": {
          "module": "env",
          "name": "memory"
        }
      },
      "wasm-gc": {
        "import-memory": {
          "module": "env",
          "name": "memory"
        }
      }
    }
  }
  ```
* The `export-memory-name` option is used to specify the name of the linear memory exported by the Wasm module.

  ```
  {
    "link": {
      "wasm": {
        "export-memory-name": "memory"
      },
      "wasm-gc": {
        "export-memory-name": "memory"
      }
    }
  }
  ```

#### Wasm Linear Backend Link Options[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#wasm-linear-backend-link-options "Link to this heading")

* The `heap-start-address` option is used to specify the starting address of the linear memory that can be used when compiling to the Wasm backend.

  For example, the following configuration sets the starting address of the linear memory to 1024.

  ```
  {
    "link": {
      "wasm": {
        "heap-start-address": 1024
      }
    }
  }
  ```

#### Wasm GC Backend Link Options[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#wasm-gc-backend-link-options "Link to this heading")

* The `use-js-string-builtin` option is used to specify whether the [JS String Builtin Proposal](https://github.com/WebAssembly/js-string-builtins/blob/main/proposals/js-string-builtins/Overview.md) should be enabled when compiling to the Wasm GC backend.
  It will make the `String` in MoonBit equivalent to the `String` in JavaScript host runtime.

  For example, the following configuration enables the JS String Builtin.

  ```
  {
    "link": {
      "wasm-gc": {
        "use-js-builtin-string": true
      }
    }
  }
  ```
* The `imported-string-constants` option is used to specify the imported string namespace used by the JS String Builtin Proposal, which is "\_" by default.
  It should meet the configuration in the JS host runtime.

  For example, the following configuration and JS initialization configures the imported string namespace.

  ```
  {
    "link": {
      "wasm-gc": {
        "use-js-builtin-string": true,
        "imported-string-constants": "_"
      }
    }
  }
  ```

  ```
  const { instance } = await WebAssembly.instantiate(bytes, {}, { importedStringConstants: "strings" });
  ```

### JS Backend Link Options[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#js-backend-link-options "Link to this heading")

* The `exports` option is used to specify the function names to export in the JavaScript module.

  For example, in the following configuration, the `hello` function from the current package is exported as the `hello` function in the JavaScript module. In the JavaScript host, the `hello` function can be called to invoke the `hello` function from the current package.

  ```
  {
    "link": {
      "js": {
        "exports": [
          "hello"
        ]
      }
    }
  }
  ```
* The `format` option is used to specify the output format of the JavaScript module.

  The currently supported formats are:

  + `esm` (default)
  + `cjs`
  + `iife`

  For example, the following configuration sets the output format of the current package to ES Module.

  ```
  {
    "link": {
      "js": {
        "format": "esm"
      }
    }
  }
  ```

### Native Backend Link Options[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#native-backend-link-options "Link to this heading")

* The `cc` option is used to specify the compiler for compiling the `moonc`-generated C source files.
  It can be either a full path to the compiler or a simple name that is accessible via the PATH environment variable.

  ```
  {
    "link": {
      "native": {
        "cc": "/usr/bin/gcc13"
      }
    }
  }
  ```
* The `cc-flags` option is used to override the default flags passed to the compiler.
  For example, you can use the following flag to define a macro called MOONBIT.

  ```
  {
    "link": {
      "native": {
        "cc-flags": "-DMOONBIT"
      }
    }
  }
  ```
* The `cc-link-flags` option is used to override the default flags passed to the linker.
  Since the linker is invoked through the compiler driver (e.g., `cc` instead of `ld`, `cl` instead of `link`),
  you should prefix specific options with `-Wl,` or `/link`  when passing them.

  The following example strips symbol information from produced binary.

  ```
  {
    "link": {
      "native": {
        "cc-link-flags": "-s"
      }
    }
  }
  ```
* The `stub-cc` option is similar to `cc` but controls which compiler to use for compiling stubs.
  Although it can be different from `cc`, it is not recommended and should only be used for debugging purposes.
  Therefore, we strongly recommend to specify `cc` and `stub-cc` at the same time
  and make them consistent to avoid potential conflicts.
* The `stub-cc-flags` is similar to `cc-flags`. It only have effects on stubs compilation.
* The `stub-cc-link-flags` are similar but have a subtle difference.
  Normally, stubs are compiled into object files and linked against object files generated from `moonc`-generated C source files.
  This linking is only controlled by `cc-flags` and `cc-link-flags`, as mentioned earlier.
  However, in specific modes, such as when the fast-debugging-test feature is enabled,
  there will be a separate linking procedure for stub objects files, where
  `stub-cc-link-flags` will take effect.

#### Default C compiler and compiler flags for the native backend[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#default-c-compiler-and-compiler-flags-for-the-native-backend "Link to this heading")

Here is a brief summarization to [compiler\_flags.rs](https://github.com/moonbitlang/moon/blob/main/crates/moonutil/src/compiler_flags.rs)

##### C Compiler[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#c-compiler "Link to this heading")

Search in PATH for the following items from top to bottom.

* cl
* gcc
* clang
* cc
* the internal tcc

For GCC-like compilers, the default compile & link command is as follows.
`[]` is used to indicate the flags may not exist in some modes.

```
cc -o $target -I$MOON_HOME/include -L$MOON_HOME/lib [-g] [-shared -fPIC] \
   -fwrapv -fno-strict-aliasing (-O2|-Og) [$MOON_HOME/lib/libmoonbitrun.o] \
   $sources -lm $cc_flags $cc_link_flags
```

For MSVC, the default compile & link command is as follows.

```
cl (/Fo|/Fe)$target -I$MOON_HOME/include [/LD] /utf-8 /wd4819 /nologo (/O2|/Od) \
   /link /LIBPATH:$MOON_HOME/lib
```

## Pre-build[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#pre-build "Link to this heading")

The `"pre-build"` field is used to specify pre-build commands, which will be executed before build commands such as `moon check|build|test`.

`"pre-build"` is an array, where each element is an object containing `input`, `output`, and `command` fields. The `input` and `output` fields can be strings or arrays of strings, while the `command` field is a string. In the `command`, you can use any shell commands, as well as the `$input` and `$output` variables, which represent the input and output files, respectively. If these fields are arrays, they will be joined with spaces by default.

Currently, there is a built-in special command `:embed`, which converts files into MoonBit source code. The `--text` parameter is used to embed text files, and `--binary` is used for binary files. `--text` is the default and can be omitted. The `--name` parameter is used to specify the generated variable name, with `resource` being the default. The command is executed in the directory where the `moon.pkg.json` file is located.

```
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

If the content of `a.txt` in the current package directory is:

```
hello,
world
```

After running `moon build`, the following `a.mbt` file will be generated in the directory where the `moon.pkg.json` is located:

```
let resource : String =
  #|hello,
  #|world
  #|
```

## Warning List[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#warning-list "Link to this heading")

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

## Alert List[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#alert-list "Link to this heading")

Disable user preset alerts.

```
{
  "alert-list": "-alert_1-alert_2"
}
```

## Virtual Package[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#virtual-package "Link to this heading")

A virtual package serves as an interface of a package that can be replaced by actual implementations.

### Declarations[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#declarations "Link to this heading")

The `virtual` field is used to declare the current package as a virtual package.

For example, the following declares a virtual package with default implementation:

```
{
  "virtual": {
    "has-default": true
  }
}
```

### Implementations[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#implementations "Link to this heading")

The `implement` field is used to declare the virtual package to be implemented by the current package.

For example, the following implements a virtual package:

```
{
  "implement": "moonbitlang/core/abort"
}
```

### Overriding implementations[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#overriding-implementations "Link to this heading")

The `overrides` field is used to provide the implementations that fulfills an imported virtual package.

For example, the following overrides the default implementation of the builtin abort package with another package:

```
{
  "overrides": ["moonbitlang/dummy_abort/abort_show_msg"]
}
```

Contents
