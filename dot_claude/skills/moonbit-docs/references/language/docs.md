---
title: "Documentation — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/language/docs"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/language/docs.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/language/docs.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Flanguage/docs.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/language/docs.md "Download source file")
* .pdf

# Documentation

## Contents

# Documentation[#](https://docs.moonbitlang.com/en/stable/language/docs.html#documentation "Link to this heading")

## Doc Comments[#](https://docs.moonbitlang.com/en/stable/language/docs.html#doc-comments "Link to this heading")

Doc comments are comments prefix with `///` in each line in the leading of toplevel structure like `fn`, `let`, `enum`, `struct` or `type`. The doc comments are written in markdown.

```
/// Return a new array with reversed elements.
fn[T] reverse(xs : Array[T]) -> Array[T] {
  ...
}
```

Markdown code block inside docstring will be considered document test,
`moon check` and `moon test` will automatically check and run these tests, so that examples in docstring are always up-to-date.
MoonBit will automatically wrap a test block around document test,
so there is no need to wrap `test { .. }` around document test:

```
/// Increment an integer by one,
///
/// Example:
/// ```
/// inspect(incr(41), content="42")
/// ```
pub fn incr(x : Int) -> Int {
  x + 1
}
```

If you want to prevent a code snippet from being treated as document test,
mark it with a language id other than `mbt` on the markdown code block:

```
/// `c_incr(x)` is the same as the following C code:
/// ```c
/// x++
/// ```
pub fn c_incr(x : Ref[Int]) -> Int {
  let old = x.val
  x.val += 1
  old
}
```

Currently, document tests are always [blackbox tests](https://docs.moonbitlang.com/en/stable/language/tests.html#blackbox-tests-and-whitebox-tests).
So private definitions cannot have document test.

## Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#attribute "Link to this heading")

Attributes are annotations placed before the top-level structure. They take the form `#attribute(...)`.
An attribute occupies the entire line, and newlines are not allowed within it.
Attributes do not normally affect the meaning of programs. Unused attributes will be reported as warnings.

### The Deprecated Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-deprecated-attribute "Link to this heading")

The `#deprecated` attribute is used to mark a function, type, or trait as deprecated.
MoonBit emits a warning when the deprecated function or type is used in other packages.
You can customize the warning message by passing a string to the attribute.

For example:

```
#deprecated
pub fn foo() -> Unit {
  ...
}

#deprecated("Use Bar2 instead")
pub(all) enum Bar {
  Ctor1
  Ctor2
}
```

### The Visibility Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-visibility-attribute "Link to this heading")

Note

This topic does not covered the access control. To lean more about `pub`, `pub(all)` and `priv`, see [Access Control](https://docs.moonbitlang.com/en/stable/language/packages.html#access-control).

The `#visibility` attribute is similar to the `#deprecated` attribute, but it is used to hint that a type will change its visibility in the future.
For outside usages, if the usage will be invalidated by the visibility change in future, a warning will be emitted.

```
// in @util package
#visibility(change_to="readonly", "Point will be readonly in the future.")
pub(all) struct Point {
  x : Int
  y : Int
}

#visibility(change_to="abstract", "Use new_text and new_binary instead.")
pub(all) enum Resource {
  Text(String)
  Binary(Bytes)
}

pub fn new_text(str : String) -> Resource {
  ...
}

pub fn new_binary(bytes : Bytes) -> Resource {
  ...
}

// in another package
fn main {
  let p = Point::{ x: 1, y: 2 } // warning
  let { x, y } = p // ok
  println(p.x) // ok
  match Resource::Text("") { // warning
    Text(s) => ... // waning
    Binary(b) => ... // warning
  }
}
```

The `#visibility` attribute takes two arguments: `change_to` and `message`.

* The `change_to` argument is a string that indicates the new visibility of the type. It can be either `"abstract"` or `"readonly"`.

  | `change_to` | Invalidated Usages |
  | --- | --- |
  | `"readonly"` | Creating an instance of the type or mutating the fields of the instance. |
  | `"abstract"` | Creating an instance of the type, mutating the fields of the instance, pattern matching, or accessing fields by label. |
* The `message` argument is a string that provides additional information about the visibility change.

### The Internal Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-internal-attribute "Link to this heading")

The `#internal` attribute is used to mark a function, type, or trait as internal.
Any usage of the internal function or type in other modules will emit an alert warning.

```
#internal(unsafe, "This is an unsafe function")
fn unsafe_get[A](https://docs.moonbitlang.com/en/stable/language/arr : Array[A]) -> A {
  ...
}
```

The internal attribute takes two arguments: `category` and `message`.
`category` is a identifier that indicates the category of the alert, and `message` is a string that provides additional message for the alert.

The alert warnings can be turn off by setting the `alert-list` in `moon.pkg.json`.
For more detail, see [Alert](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#alert-list).

### The External Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-external-attribute "Link to this heading")

The `#external` attribute is used to mark an abstract type as external type.

* For Wasm(GC) backends, it would be interpreted as `anyref`.
* For JavaScript backend, it would be interpreted as `any`.
* For native backends, it would be interpreted as `void*`.

```
#external
type Ptr
```

### The Borrow and Owned Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-borrow-and-owned-attribute "Link to this heading")

The `#borrow` and `#owned` attribute is used to indicate that a FFI takes ownership of its arguments. For more detail, see [FFI](https://docs.moonbitlang.com/en/stable/language/ffi.html#the-borrow-and-owned-attribute).

### The As Free Function Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-as-free-function-attribute "Link to this heading")

The `#as_free_fn` attribute is used to mark a method that it is declared as a free function as well.
It can also change the visibility of the free function, the name of the free function, and provide separate deprecation warning.

```
#as_free_fn(dec, visibility="pub", deprecated="use `Int::decrement` instead")
#as_free_fn(visibility="pub")
fn Int::decrement(i : Self) -> Self {
  i - 1
}

test {
  let _ = decrement(10)
  let _ = (10).decrement()
}
```

### The Callsite Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-callsite-attribute "Link to this heading")

The `#callsite` attribute is used to mark properties that happen at callsite.

It could be `autofill`, which is to autofill the arguments [SourceLoc and ArgLoc](https://docs.moonbitlang.com/en/stable/language/fundamentals.html#autofill-arguments)
at callsite.

It could also be used for migration, letting the downstream user adapt to the new calling convention:

```
#callsite(migration(y, fill=true, msg="must fill y for migration"), migration(z, fill=false, msg="cannot fill z for migration"))
fn f(x~ : Int, y? : Int = 42, z? : Int) -> Unit {
  ...
}
```

### The Skip Attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-skip-attribute "Link to this heading")

The `#skip` attribute is used to skip a single test block. The type checking will still be performed.

### The Configuration attribute[#](https://docs.moonbitlang.com/en/stable/language/docs.html#the-configuration-attribute "Link to this heading")

The `#cfg` attribute is used to perform conditional compilation. Examples are:

```
#cfg(true)
#cfg(false)
#cfg(target="wasm")
#cfg(not(target="wasm"))
#cfg(all(target="wasm", true))
#cfg(any(target="wasm", target="native"))
```

Contents
