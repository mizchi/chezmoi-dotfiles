---
title: "Managing Projects with Packages — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/language/packages"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/language/packages.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/language/packages.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Flanguage/packages.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/language/packages.md "Download source file")
* .pdf

# Managing Projects with Packages

## Contents

# Managing Projects with Packages[#](https://docs.moonbitlang.com/en/stable/language/packages.html#managing-projects-with-packages "Link to this heading")

When developing projects at large scale, the project usually needs to be divided into smaller modular unit that depends on each other.
More often, it involves using other people's work: most noticeably is the [core](https://github.com/moonbitlang/core), the standard library of MoonBit.

## Packages and modules[#](https://docs.moonbitlang.com/en/stable/language/packages.html#packages-and-modules "Link to this heading")

In MoonBit, the most important unit for code organization is a package, which consists of a number of source code files and a single `moon.pkg.json` configuration file.
A package can either be a `main` package, consisting a `main` function, or a package that serves as a library, identified by the [`is-main`](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#is-main) field.

A project, corresponding to a module, consists of multiple packages and a single `moon.mod.json` configuration file.

A module is identified by the [`name`](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#name) field, which usually consists to parts, seperated by `/`: `user-name/project-name`.
A package is identified by the relative path to the source root defined by the [`source`](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#source-directory) field. The full identifier would be `user-name/project-name/path-to-pkg`.

When using things from another package, the dependency between modules should first be declared inside the `moon.mod.json` by the [`deps`](https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html#dependency-management) field.
The dependency between packages should then be declared in side the `moon.pkg.json` by the [`import`](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#import) field.

The **default alias** of a package is the last part of the identifier split by `/`.
One can use `@pkg_alias` to access the imported entities, where `pkg_alias` is either the full identifier or the default alias.
A custom alias may also be defined with the [`import`](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#import) field.

pkgB/moon.pkg.json[#](https://docs.moonbitlang.com/en/stable/language/packages.html#id1 "Link to this code")

```
{
    "import": [
        "moonbit-community/language/packages/pkgA",
        {
            "path": "moonbit-community/language/packages/pkgC",
            "alias": "c"
        }
    ]
}
```

pkgB/top.mbt[#](https://docs.moonbitlang.com/en/stable/language/packages.html#id2 "Link to this code")

```
pub fn add1(x : Int) -> Int {
  @moonbitlang/core/int.abs(@c.incr(@pkgA.incr(x)))
}
```

### Internal Packages[#](https://docs.moonbitlang.com/en/stable/language/packages.html#internal-packages "Link to this heading")

You can define internal packages that are only available for certain packages.

Code in `a/b/c/internal/x/y/z` are only available to packages `a/b/c` and `a/b/c/**`.

## Access Control[#](https://docs.moonbitlang.com/en/stable/language/packages.html#access-control "Link to this heading")

MoonBit features a comprehensive access control system that governs which parts of your code are accessible from other packages.
This system helps maintain encapsulation, information hiding, and clear API boundaries.
The visibility modifiers apply to functions, variables, types, and traits, allowing fine-grained control over how your code can be used by others.

### Functions[#](https://docs.moonbitlang.com/en/stable/language/packages.html#functions "Link to this heading")

By default, all function definitions and variable bindings are *invisible* to other packages.
You can use the `pub` modifier before toplevel `let`/`fn` to make them public.

### Aliases[#](https://docs.moonbitlang.com/en/stable/language/packages.html#aliases "Link to this heading")

By default, all aliases, i.e. [function alias](https://docs.moonbitlang.com/en/stable/language/fundamentals.html#function-alias),
[method alias](https://docs.moonbitlang.com/en/stable/language/methods.html#alias-methods-as-functions),
[type alias](https://docs.moonbitlang.com/en/stable/language/fundamentals.html#type-alias),
[trait alias](https://docs.moonbitlang.com/en/stable/language/methods.html#trait-alias), are *invisible* to other packages.

You can use the `pub` modifier before the definition to make them public.

### Types[#](https://docs.moonbitlang.com/en/stable/language/packages.html#types "Link to this heading")

There are four different kinds of visibility for types in MoonBit:

* Private type: declared with `priv`, completely invisible to the outside world
* Abstract type: which is the default visibility for types.

  Only the name of an abstract type is visible outside, the internal representation of the
  type is hidden. Making abstract type by default is a design choice to encourage
  encapsulation and information hiding.
* Readonly types, declared with `pub`.

  The internal representation of readonly types are visible outside,
  but users can only read the values of these types from outside, construction and mutation are not allowed.
* Fully public types, declared with `pub(all)`.

  The outside world can freely construct, read values of these types and modify them if possible.

In addition to the visibility of the type itself, the fields of a public `struct` can be annotated with `priv`,
which will hide the field from the outside world completely.
Note that `struct`s with private fields cannot be constructed directly outside,
but you can update the public fields using the functional struct update syntax.

Readonly types is a very useful feature, inspired by [private types](https://ocaml.org/manual/5.3/privatetypes.html) in OCaml.
In short, values of `pub` types can be destructed by pattern matching and the dot syntax, but
cannot be constructed or mutated in other packages.

Note

There is no restriction within the same package where `pub` types are defined.

```
// Package A
pub struct RO {
  field: Int
}
test {
  let r = { field: 4 }       // OK
  let r = { ..r, field: 8 }  // OK
}

// Package B
fn println(r : RO) -> Unit {
  println("{ field: ")
  println(r.field)  // OK
  println(" }")
}
test {
  let r : RO = { field: 4 }  // ERROR: Cannot create values of the public read-only type RO!
  let r = { ..r, field: 8 }  // ERROR: Cannot mutate a public read-only field!
}
```

Access control in MoonBit adheres to the principle that a `pub` type, function, or variable cannot be defined in terms of a private type. This is because the private type may not be accessible everywhere that the `pub` entity is used. MoonBit incorporates sanity checks to prevent the occurrence of use cases that violate this principle.

```
pub(all) type T1
pub(all) type T2
priv type T3

pub(all) struct S {
  x: T1  // OK
  y: T2  // OK
  z: T3  // ERROR: public field has private type `T3`!
}

// ERROR: public function has private parameter type `T3`!
pub fn f1(_x: T3) -> T1 { ... }
// ERROR: public function has private return type `T3`!
pub fn f2(_x: T1) -> T3 { ... }
// OK
pub fn f3(_x: T1) -> T1 { ... }

pub let a: T3 = { ... } // ERROR: public variable has private type `T3`!
```

### Traits[#](https://docs.moonbitlang.com/en/stable/language/packages.html#traits "Link to this heading")

There are four visibility for traits, just like `struct` and `enum`: private, abstract, readonly and fully public.

* Private traits are declared with `priv trait`, and they are completely invisible from outside.
* Abstract trait is the default visibility. Only the name of the trait is visible from outside, and the methods in the trait are not exposed.
* Readonly traits are declared with `pub trait`, their methods can be invoked from outside, but only the current package can add new implementation for readonly traits.
* Fully public traits are declared with `pub(open) trait`, they are open to new implementations outside current package, and their methods can be freely used.

Abstract and readonly traits are sealed, because only the package defining the trait can implement them.
Implementing a sealed (abstract or readonly) trait outside its package result in compiler error.

#### Trait Implementations[#](https://docs.moonbitlang.com/en/stable/language/packages.html#trait-implementations "Link to this heading")

Implementations have independent visibility, just like functions. The type will not be considered having fulfillled the trait outside current package unless the implementation is `pub`.

To make the trait system coherent (i.e. there is a globally unique implementation for every `Type: Trait` pair),
and prevent third-party packages from modifying behavior of existing programs by accident,
MoonBit employs the following restrictions on who can define methods/implement traits for types:

* *only the package that defines a type can define methods for it*. So one cannot define new methods or override old methods for builtin and foreign types.

  + there is an exception to this rule: [local methods](https://docs.moonbitlang.com/en/stable/language/methods.html#local-method). Local methods are always private though, so they do not break coherence properties of MoonBit's type system
* *only the package of the type or the package of the trait can define an implementation*.
  For example, only `@pkg1` and `@pkg2` are allowed to write `impl @pkg1.Trait for @pkg2.Type`.

The second rule above allows one to add new functionality to a foreign type by defining a new trait and implementing it.
This makes MoonBit's trait & method system flexible while enjoying good coherence property.

Warning

Currently, an empty trait is implemented automatically.

Here's an example of abstract trait:

```
trait Number {
 op_add(Self, Self) -> Self
 op_sub(Self, Self) -> Self
}

fn[N : Number] add(x : N, y: N) -> N {
  Number::op_add(x, y)
}

fn[N : Number] sub(x : N, y: N) -> N {
  Number::op_sub(x, y)
}

impl Number for Int with op_add(x, y) { x + y }
impl Number for Int with op_sub(x, y) { x - y }

impl Number for Double with op_add(x, y) { x + y }
impl Number for Double with op_sub(x, y) { x - y }
```

From outside this package, users can only see the following:

```
trait Number

fn[N : Number] op_add(x : N, y : N) -> N
fn[N : Number] op_sub(x : N, y : N) -> N

impl Number for Int
impl Number for Double
```

The author of `Number` can make use of the fact that only `Int` and `Double` can ever implement `Number`,
because new implementations are not allowed outside.

## Virtual Packages[#](https://docs.moonbitlang.com/en/stable/language/packages.html#virtual-packages "Link to this heading")

Warning

Virtual package is an experimental feature. There may be bugs and undefined behaviors.

You can define virtual packages, which serves as an interface. They can be replaced by specific implementations at build time. Currently virtual packages can only contain plain functions.

Virtual packages can be useful when swapping different implementations while keeping the code untouched.

### Defining a virtual package[#](https://docs.moonbitlang.com/en/stable/language/packages.html#defining-a-virtual-package "Link to this heading")

You need to declare it to be a virtual package and define its interface in a MoonBit interface file.

Within `moon.pkg.json`, you will need to add field [`virtual`](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#declarations) :

```
{
  "virtual": {
    "has-default": true
  }
}
```

The `has-default` indicates whether the virtual package has a default implementation.

Within the package, you will need to add an interface file `pkg.mbti`:

/src/packages/virtual/pkg.mbti[#](https://docs.moonbitlang.com/en/stable/language/packages.html#id3 "Link to this code")

```
package "moonbit-community/language/packages/virtual"

fn log(String) -> Unit
```

The first line of the interface file need to be `package "full-package-name"`. Then comes the declarations.
The `pub` keyword for [access control](https://docs.moonbitlang.com/en/stable/language/packages.html#access-control) and the function parameter names should be omitted.

Hint

If you are uncertain about how to define the interface, you can create a normal package, define the functions you need using [TODO syntax](https://docs.moonbitlang.com/en/stable/language/fundamentals.html#todo-syntax), and use `moon info` to help you generate the interface.

### Implementing a virtual package[#](https://docs.moonbitlang.com/en/stable/language/packages.html#implementing-a-virtual-package "Link to this heading")

A virtual package can have a default implementation. By defining [`virtual.has-default`](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#declarations) as `true`, you can implement the code as usual within the same package.

/src/packages/virtual/top.mbt[#](https://docs.moonbitlang.com/en/stable/language/packages.html#id4 "Link to this code")

```
pub fn log(s : String) -> Unit {
  println(s)
}
```

A virtual package can also be implemented by a third party. By defining [`implements`](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#implementations) as the target package's full name, the compiler can warn you about the missing implementations or the mismatched implementations.

```
{
  "implement": "moonbit-community/language/packages/virtual"
}
```

/src/packages/implement/top.mbt[#](https://docs.moonbitlang.com/en/stable/language/packages.html#id5 "Link to this code")

```
pub fn log(string : String) -> Unit {
  ignore(string)
}
```

### Using a virtual package[#](https://docs.moonbitlang.com/en/stable/language/packages.html#using-a-virtual-package "Link to this heading")

To use a virtual package, it's the same as other packages: define [`import`](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#import) field in the package where you want to use it.

### Overriding a virtual package[#](https://docs.moonbitlang.com/en/stable/language/packages.html#overriding-a-virtual-package "Link to this heading")

If a virtual package has a default implementation and that is your choice, there's no extra configurations.

Otherwise, you may define the [`overrides`](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html#overriding-implementations) field by providing an array of implementations that you would like to use.

/src/packages/use\_implement/moon.pkg.json[#](https://docs.moonbitlang.com/en/stable/language/packages.html#id6 "Link to this code")

```
{
  "overrides": ["moonbit-community/language/packages/implement"],
  "import": [
    "moonbit-community/language/packages/virtual"
  ],
  "is-main": true
}
```

You should reference the virtual package when using the entities.

/src/packages/use\_implement/top.mbt[#](https://docs.moonbitlang.com/en/stable/language/packages.html#id7 "Link to this code")

```
fn main {
  @virtual.log("Hello")
}
```

Contents
