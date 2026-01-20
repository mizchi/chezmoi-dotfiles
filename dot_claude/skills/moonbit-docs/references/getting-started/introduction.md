---
title: "Introduction — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/language/introduction"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/language/introduction.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/language/introduction.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Flanguage/introduction.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/language/introduction.md "Download source file")
* .pdf

# Introduction

## Contents

# Introduction[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#introduction "Link to this heading")

A MoonBit program consists of top-level definitions including:

* type definitions
* function definitions
* constant definitions and variable bindings
* `init` functions, `main` function and/or `test` blocks.

## Expressions and Statements[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#expressions-and-statements "Link to this heading")

MoonBit distinguishes between statements and expressions. In a function body, only the last clause should be an expression, which serves as a return value. For example:

```
fn foo() -> Int {
  let x = 1
  x + 1
}

fn bar() -> Int {
  let x = 1
  //! x + 1
  x + 2
}
```

Expressions include:

* Value literals (e.g. Boolean values, numbers, characters, strings, arrays, tuples, structs)
* Arithmetical, logical, or comparison operations
* Accesses to array elements (e.g. `a[0]`), struct fields (e.g `r.x`), tuple components (e.g. `t.0`), etc.
* Variables and (capitalized) enum constructors
* Anonymous local function definitions
* `match`, `if`, `loop` expressions, etc.

Statements include:

* Named local function definitions
* Local variable bindings
* Assignments
* `return` statements
* Any expression whose return type is `Unit`, (e.g. `ignore`)

A code block can contain multiple statements and one expression, and the value of the expression is the value of the code block.

## Variable Binding[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#variable-binding "Link to this heading")

A variable can be declared as mutable or immutable using `let mut` or `let`, respectively. A mutable variable can be reassigned to a new value, while an immutable one cannot.

A constant can only be declared at top level and cannot be changed.

```
let zero = 0

const ZERO = 0

fn main {
  //! const ZERO = 0
  let mut i = 10
  i = 20
  println(i + zero + ZERO)
}
```

Note

A top level variable binding

* requires **explicit** type annotation (unless defined using literals such as string, byte or numbers)
* can't be mutable (use `Ref` instead)

## Naming conventions[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#naming-conventions "Link to this heading")

Variables, functions should start with lowercase letters `a-z` and can contain letters, numbers, underscore, and other non-ascii unicode chars.
It is recommended to name them with snake\_case.

Constants, types should start with uppercase letters `A-Z` and can contain letters, numbers, underscore, and other non-ascii unicode chars.
It is recommended to name them with PascalCase or SCREAMING\_SNAKE\_CASE.

### Keywords[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#keywords "Link to this heading")

The following are the keywords and should not be used:

```
[
  "as", "else", "extern", "fn", "fnalias", "if", "let", "const", "match", "using",
  "mut", "type", "typealias", "struct", "enum", "trait", "traitalias", "derive",
  "while", "break", "continue", "import", "return", "throw", "raise", "try", "catch",
  "pub", "priv", "readonly", "true", "false", "_", "test", "loop", "for", "in", "impl",
  "with", "guard", "async", "is", "suberror", "and", "letrec", "enumview", "noraise",
  "defer",
]
```

### Reserved Keywords[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#reserved-keywords "Link to this heading")

The following are the reserved keywords. Using them would introduce a warning.
They might be turned into keywords in the future.

```
[
  "module", "move", "ref", "static", "super", "unsafe", "use", "where", "await",
  "dyn", "abstract", "do", "final", "macro", "override", "typeof", "virtual", "yield",
  "local", "method", "alias", "assert", "package", "recur", "using", "enumview",
  "isnot", "define", "downcast", "inherit", "member", "namespace", "static", "upcast",
  "use", "void", "lazy", "include", "mixin", "protected", "sealed", "constructor",
  "atomic", "volatile", "anyframe", "anytype", "asm", "await", "comptime", "errdefer",
  "export", "opaque", "orelse", "resume", "threadlocal", "unreachable", "dynclass",
  "dynobj", "dynrec", "var", "finally", "noasync",
]
```

## Program entrance[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#program-entrance "Link to this heading")

### `init` and `main`[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#init-and-main "Link to this heading")

There is a specialized function called `init` function. The `init` function is special:

1. It has no parameter list nor return type.
2. There can be multiple `init` functions in the same package.
3. An `init` function can't be explicitly called or referred to by other functions.
   Instead, all `init` functions will be implicitly called when initializing a package. Therefore, `init` functions should only consist of statements.

```
fn init {
  let x = 1
  println(x)
}
```

There is another specialized function called `main` function. The `main` function is the main entrance of the program, and it will be executed after the initialization stage.

Same as the `init` function, it has no parameter list nor return type.

```
fn main {
  let x = 2
  println(x)
}
```

The previous two code snippets will print the following at runtime:

```
1
2
```

Only packages that are `main` packages can define such `main` function. Check out [build system tutorial](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html) for detail.

moon.pkg.json[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#id1 "Link to this code")

```
{
  "is-main": true
}
```

### `test`[#](https://docs.moonbitlang.com/en/stable/language/introduction.html#test "Link to this heading")

There's also a top-level structure called `test` block. A `test` block defines inline tests, such as:

```
test "test_name" {
  assert_eq(1 + 1, 2)
  assert_eq(2 + 2, 4)
  inspect([1, 2, 3], content="[1, 2, 3]")
}
```

The following contents will use `test` block and `main` function to demonstrate the execution result,
and we assume that all the `test` blocks pass unless stated otherwise.

Contents
