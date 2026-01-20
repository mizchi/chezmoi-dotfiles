---
title: "MoonBit for Component Model — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/toolchain/wasm/component-model-tutorial.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/toolchain/wasm/component-model-tutorial.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Ftoolchain/wasm/component-model-tutorial.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/toolchain/wasm/component-model-tutorial.md "Download source file")
* .pdf

# MoonBit for Component Model

## Contents

# MoonBit for Component Model[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#moonbit-for-component-model "Link to this heading")

This guide demonstrates how to build WebAssembly components using MoonBit,
leveraging WIT (WebAssembly Interface Types) for interface definitions and the
`wit-bindgen` toolchain for code generation.

This tutorial walks through building a component that implements the
[`adder` world](https://github.com/bytecodealliance/component-docs/tree/main/component-model/examples/tutorial/wit/adder/world.wit) defined in the `docs:adder` package. The component
will export an `add` interface containing an `add` function that sums two
numbers.

## 1. Install the Tools[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#install-the-tools "Link to this heading")

### Installing MoonBit[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#installing-moonbit "Link to this heading")

First, install the MoonBit compiler and toolchain. Follow the installation
instructions from the
[MoonBit download page](https://www.moonbitlang.com/download).

Verify your MoonBit installation (below are the versions at the time of
writing):

```
$ moon version --all
moon 0.1.20250826 (8ab6c9e 2025-08-26) ~/.moon/bin/moon
moonc v0.6.25+d6913262c (2025-08-27) ~/.moon/bin/moonc
moonrun 0.1.20250826 (8ab6c9e 2025-08-26) ~/.moon/bin/moonrun
moon-pilot 0.0.1-95f12db ~/.moon/bin/moon-pilot
```

### Installing Wasm toolchain[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#installing-wasm-toolchain "Link to this heading")

1. Install the `wit-bindgen` CLI tool, which generates MoonBit bindings from WIT
   files:

   ```
   $ cargo install wit-bindgen-cli
   ```
2. Install `wasm-tools` for working with WebAssembly components:

   ```
   $ cargo install wasm-tools
   ```

Verify the installations (below are the versions at the time of writing):

```
$ wit-bindgen --version
wit-bindgen-cli 0.45.0
$ wasm-tools --version
wasm-tools 1.238.0
```

## 2. Define the Interface (WIT)[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#define-the-interface-wit "Link to this heading")

Before generating the MoonBit project, you need to define the component
interface using WIT. Create a directory for your project and define the WIT
file:

```
$ mkdir moonbit-adder && cd moonbit-adder
$ mkdir wit
```

Create `wit/world.wit` with the following content:

```
package docs:adder@0.1.0;

interface add {
    add: func(x: u32, y: u32) -> u32;
}

world adder {
    export add;
}
```

This WIT definition:

* Declares a package `docs:adder` with version `0.1.0`
* Defines an `add` interface with a single function that takes two `u32`
  parameters and returns a `u32`
* Creates an `adder` world that exports the `add` interface

## 3. Generate MoonBit Project Structure[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#generate-moonbit-project-structure "Link to this heading")

Use `wit-bindgen` to generate the MoonBit project structure and bindings:

```
$ wit-bindgen moonbit wit/world.wit --out-dir . \
    --derive-eq \
    --derive-show \
    --derive-error
```

This command generates the following directory structure:

```
.
├── ffi
│   ├── moon.pkg.json
│   └── top.mbt
├── gen
│   ├── ffi.mbt
│   ├── gen_interface_docs_adder_add_export.mbt
│   ├── interface
│   │   └── docs
│   │       └── adder
│   │           └── add
│   │               ├── moon.pkg.json
│   │               ├── stub.mbt
│   │               └── top.mbt
│   ├── moon.pkg.json
│   ├── world
│   │   └── adder
│   │       ├── moon.pkg.json
│   │       └── stub.mbt
│   └── world_adder_export.mbt
├── moon.mod.json
├── wit
│   └── world.wit
└── world
    └── adder
        ├── ffi_import.mbt
        ├── import.mbt
        ├── moon.pkg.json
        └── top.mbt
```

The generated files include:

* `moon.mod.json`: MoonBit module configuration
* `gen/`: Generated export bindings

  + `interface/`: Generated export interface bindings
  + `world/`: Generated export world bindings
  + `stub.mbt`: Main implementation file
* `interface/`: Generated import interface bindings
* `world/`: Generated import world bindings

## 4. Examine the Generated Code[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#examine-the-generated-code "Link to this heading")

The `wit-bindgen` tool generates MoonBit bindings that handle the WebAssembly
component interface. Let's examine the generated
`gen/interface/docs/adder/add/stub.mbt`:

```
// Generated by `wit-bindgen` 0.45.0.

pub fn add(_x : UInt, _y : UInt) -> UInt {
      ...
}
```

The `...` is the placeholder syntax in MoonBit. When executing
`moon check --target wasm`, 'unfinished code' warnings will appear.

## 5. Implement the Component Logic[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#implement-the-component-logic "Link to this heading")

Now implement the `add` function in `gen/interface/docs/adder/add/stub.mbt`:

```
// Generated by `wit-bindgen` 0.45.0.

///|
pub fn add(x : UInt, y : UInt) -> UInt {
  x + y
}
```

## 6. Configure the Build[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#configure-the-build "Link to this heading")

Ensure your `gen/moon.pkg.json` is properly configured for WebAssembly target:

```
{
  // link configuration for Wasm backend
  "link": {
    "wasm": {
      "exports": [
        // Export for cabi_realloc
        "cabi_realloc:cabi_realloc",
        // Export per the interface definition
        "wasmExportAdd:docs:adder/add@0.1.0#add"
      ],
      "export-memory-name": "memory",
      "heap-start-address": 16
    }
  },
  "import": [
    {
      "path": "docs/adder/ffi",
      "alias": "ffi"
    },
    {
      "path": "docs/adder/gen/interface/docs/adder/add",
      "alias": "add"
    }
  ]
}
```

## 7. Build the WebAssembly Component[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#build-the-webassembly-component "Link to this heading")

Build the MoonBit code to WebAssembly:

```
$ moon build --target wasm
```

This generates a WebAssembly module. To create a proper WebAssembly component,
use `wasm-tools`:

```
$ wasm-tools component embed wit target/wasm/release/build/gen/gen.wasm \
    --encoding utf16 \
    --output adder.wasm
$ wasm-tools component new adder.wasm --output adder.component.wasm
```

You can verify the component's interface using `wasm-tools`:

```
$ wasm-tools component wit adder.component.wasm
```

Expected output for both commands:

```
package root:component;

world root {
  export docs:adder/add@0.1.0;
}
package docs:adder@0.1.0 {
  interface add {
    add: func(x: u32, y: u32) -> u32;
  }
}
```

## 8. Testing the Component[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#testing-the-component "Link to this heading")

### Using the Example Host[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#using-the-example-host "Link to this heading")

To test your component, use the [`example-host`](https://github.com/bytecodealliance/component-docs/blob/main/component-model/examples/example-host/README.md) provided in this
repository:

```
$ git clone https://github.com/bytecodealliance/component-docs.git
$ cd component-docs/component-model/examples/example-host
$ cp /path/to/adder.component.wasm .
$ cargo run --release -- 5 3 adder.component.wasm
```

Expected output:

```
5 + 3 = 8
```

### Using Wasmtime[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#using-wasmtime "Link to this heading")

You can also test the component directly with `wasmtime`:

```
$ wasmtime run --invoke 'add(10, 20)' adder.component.wasm
30
```

## 9. Configurations[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#configurations "Link to this heading")

### --derive-eq --derive-show[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#derive-eq-derive-show "Link to this heading")

These two options will add `derive(Eq)` and / or `derive(Show)` for all the
generated types.

### --derive-error[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#derive-error "Link to this heading")

This option will generate variants / enums whose names containing 'Error' as
[suberrors](https://docs.moonbitlang.com/en/latest/language/error-handling.html#error-types).
This allows you to integrate the MoonBit's error handling easier.

For example, for the following interface:

```
package docs:adder@0.1.0;

interface add {
    variant computation-error {
        overflow
    }
    add: func(x: u32, y: u32) -> result<u32, computation-error>;
}

world adder {
    import add;
}
```

Will generate the following type and function:

```
// Generated by `wit-bindgen` 0.45.0. DO NOT EDIT!

///|
pub(all) suberror ComputationError {
  Overflow
} derive(Show, Eq)

///|
pub fn add(x : UInt, y : UInt) -> Result[UInt, ComputationError] {
  ...
}
```

which you may use it as:

```
// Generated by `wit-bindgen` 0.45.0.

///|
fn init {
  let _ = @add.add(1, 2).unwrap_or_error() catch { Overflow => ... }

}
```

### --ignore-stub[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#ignore-stub "Link to this heading")

It happens when you would like to regenerate the project due to the updated
interface, but you don't want the `stub` file to be touched. You may use
`--ignore-stub` option to avoid such modifications.

### --project-name[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#project-name "Link to this heading")

By default, the project name is generated per the name defined in the MoonBit
file. You may use this option to specify the name of the project. It can also be
used if you are generating the project as part of a larger project.

### --gen-dir[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#gen-dir "Link to this heading")

By default, the exportation parts are generated under `gen`. You may use this
option to specify another directory.

## 10. References and Further Reading[#](https://docs.moonbitlang.com/en/stable/toolchain/wasm/component-model-tutorial.html#references-and-further-reading "Link to this heading")

* [WebAssembly Component Model](https://component-model.bytecodealliance.org/)
* [Component Model Examples](https://github.com/bytecodealliance/component-docs/tree/main/component-model/examples)
* [WIT Format Specification](https://component-model.bytecodealliance.org/design/wit.html)
* [`wit-bindgen`](https://github.com/bytecodealliance/wit-bindgen)
* [WebAssembly Tools](https://github.com/bytecodealliance/wasm-tools)
* [Wasmtime Runtime](https://wasmtime.dev/)

Contents
