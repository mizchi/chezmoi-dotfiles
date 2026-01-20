---
title: "Error handling — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/language/error-handling"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/language/error-handling.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/language/error-handling.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Flanguage/error-handling.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/language/error-handling.md "Download source file")
* .pdf

# Error handling

## Contents

# Error handling[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#error-handling "Link to this heading")

Error handling has always been at core of our language design. In the following
we'll be explaining how error handling is done in MoonBit. We assume you have
some prior knowledge of MoonBit, if not, please checkout
[A tour of MoonBit](https://docs.moonbitlang.com/en/stable/tutorial/tour.html).

## Error Types[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#error-types "Link to this heading")

In MoonBit, all the error values can be represented by the `Error` type, a
generalized error type.

However, an `Error` cannot be constructed directly. A concrete error type must
be defined, in the following forms:

```
suberror E1 Int // error type E1 has one constructor E1 with an Int payload

suberror E2 // error type E2 has one constructor E2 with no payload

suberror E3 { // error type E3 has three constructors like a normal enum type
  A
  B(Int, x~ : String)
  C(mut x~ : String, Char, y~ : Bool)
}
```

The error types can be promoted to the `Error` type automatically, and pattern
matched back:

```
suberror CustomError UInt

test {
  let e : Error = CustomError(42)
  guard e is CustomError(m)
  assert_eq(m, 42)
}
```

Since the type `Error` can include multiple error types, pattern matching on the
`Error` type must use the wildcard `_` to match all error types. For example,

```
fn f(e : Error) -> Unit {
  match e {
    E2 => println("E2")
    A => println("A")
    B(i, x~) => println("B(\{i}, \{x})")
    _ => println("unknown error")
  }
}
```

The `Error` is meant to be used where no concrete error type is needed, or a
catch-all for all kinds of sub-errors is needed.

### Failure[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#failure "Link to this heading")

A builtin error type is `Failure`.

There's a handly `fail` function, which is merely a constructor with a
pre-defined output template for showing both the error and the source location.
In practice, `fail` is always preferred over `Failure`.

```
#callsite(autofill(loc))
pub fn[T] fail(msg : String, loc~ : SourceLoc) -> T raise Failure {
  raise Failure("FAILED: \{loc} \{msg}")
}
```

## Throwing Errors[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#throwing-errors "Link to this heading")

The keyword `raise` is used to interrupt the function execution and return an
error.

The type declaration of a function can use `raise` with an Error type to
indicate that the function might raise an error during an execution. For
example, the following function `div` might return an error of type `DivError`:

```
suberror DivError String

fn div(x : Int, y : Int) -> Int raise DivError {
  if y == 0 {
    raise DivError("division by zero")
  }
  x / y
}
```

The `Error` can be used when the concrete error type is not important. For
convenience, you can omit the error type after the `raise` to indicate that the
`Error` type is used. For example, the following function signatures are
equivalent:

```
fn f() -> Unit raise {
  ...
}

fn g() -> Unit raise Error {
  let h : () -> Unit raise = fn() raise { fail("fail") }
  ...
}
```

For functions that are generic in the error type, you can use the `Error` bound
to do that. For example,

```
// Result::unwrap_or_error
fn[T, E : Error] unwrap_or_error(result : Result[T, E]) -> T raise E {
  match result {
    Ok(x) => x
    Err(e) => raise e
  }
}
```

For functions that do not raise an error, you can add `noraise` in the
signature. For example:

```
fn add(a : Int, b : Int) -> Int noraise {
  a + b
}
```

### Error Polymorphism[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#error-polymorphism "Link to this heading")

It happens when a higher order function accepts another function as parameter.
The function as parameter may or may not throw error, which in turn affects the
behavior of this function.

A notable example is `map` of `Array`:

```
fn[T] map(array : Array[T], f : (T) -> T raise) -> Array[T] raise {
  let mut res = []
  for x in array {
    res.push(f(x))
  }
  res
}
```

However, writing so would make the `map` function constantly having the
possibility of throwing errors, which is not the case.

Thus, the error polymorphism is introduced. You may use `raise?` to signify that
an error may or may not be throw.

```
fn[T] map_with_polymorphism(
  array : Array[T],
  f : (T) -> T raise?
) -> Array[T] raise? {
  let mut res = []
  for x in array {
    res.push(f(x))
  }
  res
}

fn[T] map_without_error(array : Array[T], f : (T) -> T noraise) -> Array[T] noraise {
  map_with_polymorphism(array, f)
}

fn[T] map_with_error(array : Array[T], f : (T) -> T raise) -> Array[T] raise {
  map_with_polymorphism(array, f)
}
```

The signature of the `map_with_polymorphism` will be determined by the actual
parameter.

## Handling Errors[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#handling-errors "Link to this heading")

Applying the function normally will rethrow the error directly in case of an
error. For example:

```
fn div_reraise(x : Int, y : Int) -> Int raise DivError {
  div(x, y) // Rethrow the error if `div` raised an error
}
```

However, you may want to handle the errors.

### Try ... Catch[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#try-catch "Link to this heading")

You can use `try` and `catch` to catch and handle errors, for example:

```
fn main {
  try div(42, 0) catch {
    DivError(s) => println(s)
  } noraise {
    v => println(v)
  }
}
```

Output[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#id1 "Link to this code")

```
division by zero
```

Here, `try` is used to call a function that might throw an error, and `catch` is
used to match and handle the caught error. If no error is caught, the catch
block will not be executed and the `noraise` block will be executed instead.

The `noraise` block can be omitted if no action is needed when no error is
caught. For example:

```
try { println(div(42, 0)) } catch {
  _ => println("Error")
}
```

When the body of `try` is a simple expression, the curly braces, and even the
`try` keyword can be omitted. For example:

```
let a = div(42, 0) catch { _ => 0 }
println(a)
```

### Transforming to Result[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#transforming-to-result "Link to this heading")

You can also catch the potential error and transform into a first-class value of
the [`Result`](https://docs.moonbitlang.com/en/stable/language/fundamentals.html#option-and-result) type, by using
`try?` before an expression that may throw error:

```
test {
  let res = try? (div(6, 0) * div(6, 3))
  inspect(
    res,
    content=(
      #|Err("division by zero")
    ),
  )
}
```

### Panic on Errors[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#panic-on-errors "Link to this heading")

You can also panic directly when an unexpected error occurs:

```
fn remainder(a : Int, b : Int) -> Int raise DivError {
  if b == 0 {
    raise DivError("division by zero")
  }
  let div = try! div(a, b)
  a - b * div
}
```

### Error Inference[#](https://docs.moonbitlang.com/en/stable/language/error-handling.html#error-inference "Link to this heading")

Within a `try` block, several different kinds of errors can be raised. When that
happens, the compiler will use the type `Error` as the common error type.
Accordingly, the handler must use the wildcard `_` to make sure all errors are
caught, and `e => raise e` to reraise the other errors. For example,

```
fn f1() -> Unit raise E1 {
  ...
}

fn f2() -> Unit raise E2 {
  ...
}

try {
  f1()
  f2()
} catch {
  E1(_) => ...
  E2 => ...
  e => raise e
}
```

Contents
