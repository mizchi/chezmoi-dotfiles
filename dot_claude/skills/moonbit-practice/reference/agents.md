----
title: MoonBit Project Layouts
----

# MoonBit Project Layouts

You have the ability to detect specific types of MoonBit projects and work with
them adaptively.

MoonBit source files use the `.mbt` extension and interface files `.mbti`. At
the top-level of a MoonBit project there is a `moon.mod.json` file specifying
the metadata of the project. The project may contain multiple packages, each
with its own `moon.pkg.json` file.

Here are some typical project layouts you may encounter:

- **Module**: When you see a `moon.mod.json` file in the project directory, you
  are already in a MoonBit project.
  A MoonBit *module* is like a Go module.
  It is a collection of packages, usually corresponding to a repository or project.
  Module boundaries matter for dependency management and import paths.
  A module contains many packages in subdirectories.

- **Package**: When you see a `moon.pkg.json` file, but not a `moon.mod.json`
  file, it means you are in a MoonBit package. All subcommands of `moon` will
  still be executed in the directory of the module (where `moon.mod.json` is
  located), not the current package.
  A MoonBit *package* is the actual compilation unit (like a Go package).
  All source files in the same package are concatenated into one unit.
  The `package` name in the source defines the package, not the file name.
  Imports refer to module + package paths, NEVER to file names.

- **Files**:
  A `.mbt` file is just a chunk of source inside a package.
  File names do NOT create modules or namespaces.
  You may freely split/merge/move declarations between files in the same package.
  Any declaration in a package can reference any other declaration in that package, regardless of file.

## Coding/layout rules you MUST follow:

1. Prefer many small, cohesive files over one large file.
   - Group related types and functions into focused files (e.g. http_client.mbt, router.mbt).
   - If a file is getting large or unfocused, create a new file and move related declarations into it.

2. You MAY freely move declarations between files inside the same package.
   - Moving a function/struct/trait between files does not change semantics, as long as its name and pub-ness stay the same.
   - It is safe to refactor by splitting or merging files inside a package.

3. File names are purely organizational.
   - Do NOT assume file names define modules, and do NOT use file names in type paths.
   - Choose file names to describe a feature or responsibility, not to mirror type names rigidly.

4. When adding new code:
   - Prefer adding it to an existing file that matches the feature.
   - If no good file exists, create a new file under the same package with a descriptive name.
   - Avoid creating giant “misc” or “util” files.

5. Tests:
   - Place tests in dedicated test files (e.g. *_test.mbt) within the appropriate package.
   - It is fine—and encouraged—to have multiple small test files.

## `.mbti` Files - Package Interface Documentation

MoonBit interface files (`pkg.generated.mbti`) are compiler-generated summaries of each package's public API surface. They provide a formal, concise overview of all exported types, functions, and traits without implementation details.

**Standard library interfaces** are available in `~/.moon/lib/core`:

```
$ tree -P '*.mbti' -I 'internal' --prune ~/.moon/lib/core # ignore internal packages
/Users/username/.moon/lib/core
├── builtin
│   └── pkg.generated.mbti
├── array
│   └── pkg.generated.mbti
├── bench
│   └── pkg.generated.mbti
├── bigint
│   └── pkg.generated.mbti
.....
```

**When to use each approach**:
- Use `moon doc` for interactive API discovery (preferred, see "API Discovery with `moon doc`" section below)
- Read `.mbti` files directly when you need the complete API surface at once or when working offline

**Reading `.mbti` files for API discovery**:
- **Start with `builtin/pkg.generated.mbti`** - contains core types (String, Int, Array, etc.) and their fundamental APIs
- **Note**: Some builtin types like `String` expose APIs in both `builtin` and their dedicated packages (e.g., `String`)
- **Local dependencies**: Find `.mbti` files in the `.mooncakes` directory by searching for `pkg.generated.mbti`
- **Your own packages**: After running `moon info`, check the generated `.mbti` in each package directory to verify public API changes
# MoonBit Language Fundamentals

## Core Facts

Core facts that impact how you write and refactor code.

- **Expression‑oriented**: `if`, `match`, loops return values; last expression is the return.
- **References by default**: Arrays/Maps/structs mutate via reference; use `Ref[T]` for primitive mutability.
- **Errors**: Functions declare `raise ...`; use `try?` for `Result` or `try { } catch { }` to handle.
- **Blocks**: Separate top‑level items with `///|`. Generate code block‑by‑block.
- **Visibility**: `fn` private by default; `pub` exposes read/construct as allowed; `pub(all)` allows external construction.
- **Naming convention**: lower_snake for values/functions; UpperCamel for types/enums; enum variants start UpperCamel.
- **Packages**: No `import` in code files; call via `@alias.fn`. Configure imports in `moon.pkg.json`.
- **Placeholders**: `...` is a valid placeholder in MoonBit code for incomplete implementations.
- **Global values**: immutable by default and generally require type annotations.
- **Garbage collection**: MoonBit has a GC, there is no lifetime annotation, there's no ownership system.
<Important> Delimit top-level items with `///|` comments so tools can split the file reliably.
</Important>

Quick reference:

```mbt check
///|
/// comments doc string
pub fn sum(x : Int, y : Int) -> Int {
  x + y
}

///|
/// error declaration and usage
suberror MySubError

///|
fn risky() -> Int raise MySubError {
  raise MySubError::MySubError
}

///|
struct Rect {
  width : Int
  height : Int
}

///|
fn Rect::area(self : Rect) -> Int {
  self.width * self.height
}

///|
pub impl Show for Rect with output(_self, logger) {
  logger.write_string("Rect")
}

///|
enum MyOption {
  MyNone
  MySome(Int)
} derive(Show, ToJson, Eq, Compare)

///|
///  match + loops are expressions
test "everything is expression in MoonBit" {
  // tuple
  let (n, opt) = (1, MySome(2))
  // if expressions return values
  let msg : String = if n > 0 { "pos" } else { "non-pos" }
  let res = match opt {
    MySome(x) => {
      inspect(x, content="2")
      1
    }
    MyNone => 0
  }
  let status : Result[Int, String] = Ok(10)
  // match expressions return values
  let description = match status {
    Ok(value) => "Success: \{value}"
    Err(error) => "Error: \{error}"
  }
  let array = [1, 2, 3, 4, 5]
  let mut i = 0 // mutable bindings (local only, globals are immutable)
  let target = 3
  // loops return values with 'break'
  let found : Int? = while i < array.length() {
    if array[i] == target {
      break Some(i) // Exit with value
    }
    i = i + 1
  } else { // Value when loop completes normally
    None
  }
  assert_eq(found, Some(2)) // Found at index 2
}

///|
/// global bindings
pub let my_name : String = "MoonBit"

///|
pub const PI : Double = 3.14159 // constants use UPPER_SNAKE or PascalCase

///|
pub fn maximum(xs : Array[Int]) -> Int raise {
  // Toplevel functions are *mutually recursive* by default
  // `raise` annotation means the function would raise any Error
  //  Only add `raise XXError` when you do need track the specific error type
  match xs {
    [] => fail("Empty array") // fail() is built-in for generic errors
    [x] => x
    // pattern match over array, the `.. rest` is a rest pattern
    // it is of type `ArrayView[Int]` which is a slice
    [x, .. rest] => {
      let mut max_val = x // `mut` only allowed in local bindings
      for y in rest {
        if y > max_val {
          max_val = y
        }
      }
      max_val // return can be omitted if the last expression is the return value
    }
  }
}

///|
/// pub(all) means it can be both read and created outside the package
pub(all) struct Point {
  x : Int
  mut y : Int
} derive(Show, ToJson)

///|
pub enum MyResult[T, E] {
  MyOk(T) // semicolon `;` is optional when we have a newline
  MyErr(E) // Enum variants must start uppercase
} derive(Show, Eq, ToJson)
// pub means it can only be pattern matched outside the package
// but it can not be created outside the package, use `pub(all)` otherwise

///|
/// pub (open) means the trait can be implemented for outside packages
pub(open) trait Comparable {
  compare(Self, Self) -> Int // `Self` refers to the implementing type
}

///|
test "inspect test" {
  let result = sum(1, 2)
  inspect(result, content="3")
  // The `content` can be auto-corrected by running `moon test --update`
  let point = Point::{ x: 10, y: 20 }
  // For complex structures, use @json.inspect for better readability:
  @json.inspect(point, content={ "x": 10, "y": 20 })
}
```

## Integers, Char

MoonBit supports Byte, Int16, Int, UInt16, UInt, Int64, UInt64, etc. When the type is known,
the literal can be overloaded:

```mbt check
test "integer and char literal overloading disambiguation via type in the current context" {
  let a0 = 1 // a is Int by default
  let (int, uint, uint16, int64, byte) : (Int, UInt, UInt16, Int64, Byte) = (
    1, 1, 1, 1, 1,
  )
  assert_eq(int, uint16.to_int())
  let a1 : Int = 'b' // this also works, a5 will be the unicode value
  let a2 : Char = 'b'
}
```
## Bytes

Bytes is immutable; Indexing (`b[i]`) returns a `Byte`.

```mbt check
test "bytes literals overloading and indexing" {
  let b0 : Bytes = b"abcd"
  let b1 : Bytes = "abcd" // b" prefix is optional, when we know the type
  let b2 : Bytes = [0xff, 0x00, 0x01] // Array literal overloading
  assert_eq(b0[0], b'a') // indexing returns Byte
}
```
## Array

MoonBit Array is resizable array, FixedArray is fixed size array.

```mbt check
///|
test "array literals overloading: disambiguation via type in the current context" {
  let a0 : Array[Int] = [1, 2, 3] // resizable
  let a1 : FixedArray[Int] = [1, 2, 3]
  let a2 : ReadOnlyArray[Int] = [1, 2, 3]
  let a3 : ArrayView[Int] = [1, 2, 3]

}
```

## String

MoonBit's String is immutable utf16 encoded, `s[i]` returns a code unit (UInt16),
`s.get_char(i)` returns `Option[Char]`.
Since MoonBit supports char literal overloading, you can write code snippets like this:

```mbt check
#warnings("-unused_value")
test "string indexing and utf8 encode/decode" {
  let s = "hello world"
  let b0 : UInt16 = s[0]
  assert_true(b0 is ('\n' | 'h' | 'b' | 'a'..='z'))
  // In check mode (expression with explicit type), ('\n' : Int) is valid.
  // Here the compiler knows `s[i]` is Int

  // Using get_char for Option handling
  let b1 : Char? = s.get_char(0)
  assert_true(b1 is Some('a'..='z'))

  // ⚠️ Important: Variables won't work with direct indexing
  let eq_char : Char = '='
  // s[0] == eq_char // ❌ Won't compile - eq_char is not a literal, lhs is UInt while rhs is Char
  // Use: s[0] == '=' or s.get_char(0) == Some(eq_char)
  let bytes = @encoding/utf8.encode("中文") // utf8 encode package is in stdlib
  assert_true(bytes is [0xe4, 0xb8, 0xad, 0xe6, 0x96, 0x87])
  let s2 : String = @encoding/utf8.decode(bytes) // decode utf8 bytes back to String
  assert_true(s2 is "中文")
}
```

#### String Interpolation

MoonBit uses `\{}` for string interpolation:

```mbt check
test "string interpolation basics" {
  let point : Point = { x: 10, y: 20 }
  let name : String = "Moon"
  let config = { "cache": 123 }
  let version = 1.0
  let message = "Hello \{name} v\{version}" // "Hello Moon v1.0"
  let desc = "Point at \{point}" // Uses point.to_string()
  // Works with any type implementing Show

  // ❌ Wrong - quotes inside interpolation not allowed:
  // println("  - Checking if 'cache' section exists: \{config["cache"]}")

  // ✅ Correct - extract to variable first:
  let has_key = config["cache"] // `"` not allowed in interpolation
  println("  - Checking if 'cache' section exists: \{has_key}")
}
```

<Important> expressions inside `\{}` can only be basic expressions (no quotes, newlines, or nested interpolations). String literals are not allowed as it makes lexing too difficult.
</Important>

#### Multiple line strings

```mbt check
///|
test "multi-line string literals" {
  let multi_line_string : String =
    #|Hello
    #|World
    #|
  inspect(
    multi_line_string,
    content=(
      #|Hello
      #|World
      #|
    ), // when multiple line string is passed as argument, `()` wrapper is required
  )
}
```

## Map

A built-in `Map` type that preserves insertion order (like
JavaScript's Map):

```mbt check
///|
test "map literals and common operations" {
  // Map literal syntax
  let map : Map[String, Int] = { "a": 1, "b": 2, "c": 3 }

  // Empty map
  let empty : Map[String, Int] = {}

  // From array of pairs
  let from_pairs : Map[String, Int] = Map::from_array([("x", 1), ("y", 2)])

  // Set/update value
  map["new-key"] = 3
  map["a"] = 10 // Updates existing key

  // Get value - returns Option[T]
  assert_eq(map.get("new-key"), Some(3))
  assert_eq(map.get("missing"), None)

  // Direct access (panics if key missing)
  let value : Int = map["a"] // value = 10

  // Iteration preserves insertion order
  for k, v in map {
    println("\{k}: \{v}") // Prints: a: 10, b: 2, c: 3, new-key: 3
  }

  // Other common operations
  map.remove("b")
  assert_eq(map.contains("b"), false)
  assert_eq(map.length(), 3)
}
```

## View Types

**Key Concept**: View types (`StringView`, `BytesView`, `ArrayView[T]`) are zero-copy, non-owning read-only slices created with the `[:]` syntax. They don't allocate memory and are ideal for passing sub-sequences without copying data.

- `String` → `StringView` via `s[:]` or `s[start:end]`
- `Bytes` → `BytesView` via `b[:]` or `b[start:end]`
- `Array[T]` → `ArrayView[T]` via `a[:]` or `a[start:end]`

**Important**: StringView slice is slightly different due to unicode safety:
`s[a:b]` may raise an error at surrogate boundaries (UTF-16 encoding edge case). You have two options:

- Use `try! s[a:b]` if you're certain the boundaries are valid (crashes on invalid boundaries)
- Let the error propagate to the caller for proper handling

**When to use views**:

- Pattern matching with rest patterns (`[first, .. rest]`)
- Passing slices to functions without allocation overhead
- Avoiding unnecessary copies of large sequences

Convert back with `.to_string()`, `.to_bytes()`, or `.to_array()` when you need ownership.

## Complex Types

```mbt check
///|
type UserId = Int // Int is aliased to UserId - like symlink

///|
///  Tuple-struct for callback
struct Handler((String) -> Unit) // A newtype wrapper

///|
/// Tuple-struct syntax for single-field newtypes
struct Meters(Int) // Tuple-struct syntax

///|
let distance : Meters = Meters(100)

///|
let raw : Int = distance.0 // Access first field with .0

///|
struct Addr {
  host : String
  port : Int
} derive(Show, Eq, ToJson, FromJson)

///|
/// Structural types with literal syntax
let config : Addr = {
  // `Type::` can be omitted if the type is already known
  // otherwise `Type::{...}`
  host: "localhost",
  port: 8080,
}

///|
/// Recursive enum for trees
enum Tree[T] {
  Leaf(T)
  Node(left~ : Tree[T], T, right~ : Tree[T]) // enum can use labels
}

// Pattern match on enum variants

///|
fn sum_tree(tree : Tree[Int]) -> Int {
  match tree {
    Leaf(x) => x
    Node(left~, x, right~) => sum_tree(left) + x + sum_tree(right)
  }
}
```

## Common Derivable Traits

Most types can automatically derive standard traits using the `derive(...)` syntax:

- **`Show`** - Enables `to_string()` and string interpolation with `\{value}`
- **`Eq`** - Enables `==` and `!=` equality operators
- **`Compare`** - Enables `<`, `>`, `<=`, `>=` comparison operators
- **`ToJson`** - Enables `@json.inspect()` for readable test output
- **`Hash`** - Enables use as Map keys

```mbt check
///|
struct Coordinate {
  x : Int
  y : Int
} derive(Show, Eq, ToJson)

///|
enum Status {
  Active
  Inactive
} derive(Show, Eq, Compare)
```

**Best practice**: Always derive `Show` and `Eq` for data types. Add `ToJson` if you plan to test them with `@json.inspect()`.

## Reference Semantics by Default

MoonBit passes most types by reference semantically (the optimizer may copy
immutables):

```mbt check
///|
///  Structs with 'mut' fields are always passed by reference
struct Counter {
  mut value : Int
}

///|
fn increment(c : Counter) -> Unit {
  c.value += 1 // Modifies the original
}

///|
/// Arrays and Maps are mutable references
fn modify_array(arr : Array[Int]) -> Unit {
  arr[0] = 999 // Modifies original array
}

///|
///  Use Ref[T] for explicit mutable references to primitives
fn swap_values(a : Ref[Int], b : Ref[Int]) -> Unit {
  let temp = a.val
  a.val = b.val
  b.val = temp
}

///|
test "ref swap" {
  let x : Ref[Int] = Ref::new(10)
  let y : Ref[Int] = Ref::new(20)
  swap_values(x, y) // x.val is now 20, y.val is now 10
}
```

## Pattern Matching

MoonBit's pattern matching is comprehensive and exhaustive:

```mbt check
///|
/// Destructure arrays with rest patterns
fn process_array(arr : Array[Int]) -> String {
  match arr {
    [] => "empty"
    [single] => "one: \{single}"
    [first, .. _middle, last] => "first: \{first}, last: \{last}"
    // middle is of type ArrayView[Int]
  }
}

///|
fn analyze_point(point : Point) -> String {
  match point {
    { x: 0, y: 0 } => "origin"
    { x, y } if x == y => "on diagonal"
    { x, .. } if x < 0 => "left side"
    _ => "other"
  }
}

///|
/// StringView pattern matching for parsing
fn is_palindrome(s : StringView) -> Bool {
  loop s {
    [] | [_] => true
    [a, .. rest, b] if a == b => continue rest
    // a is of type Char, rest is of type StringView
    _ => false
  }
}
```

## Functional `loop` control flow

The `loop` construct is unique to MoonBit:

```mbt check
///|
/// Functional loop with pattern matching on loop variables
/// @list.List is from the standard library
fn sum_list(list : @list.List[Int]) -> Int {
  loop (list, 0) {
    (Empty, acc) => acc // Base case returns accumulator
    (More(x, tail=rest), acc) => continue (rest, x + acc) // Recurse with new values
  }
}

///|
///  Multiple loop variables with complex control flow
fn find_pair(arr : Array[Int], target : Int) -> (Int, Int)? {
  loop (0, arr.length() - 1) {
    (i, j) if i >= j => None
    (i, j) => {
      let sum = arr[i] + arr[j]
      if sum == target {
        Some((i, j)) // Found pair
      } else if sum < target {
        continue (i + 1, j) // Move left pointer
      } else {
        continue (i, j - 1) // Move right pointer
      }
    }
  }
}
```

**Note**: You must provide a payload to `loop`. If you want an infinite loop, use `while true { ... }` instead. The syntax `loop { ... }` without arguments is invalid.

## Functional `for` control flow

`for` loops have unique MoonBit features:

```mbt check
///|
test "functional for loop control flow" {
  // For loop with multiple loop variables,
  // i and j are loop state
  let sum_result : Int = for i = 0, sum = 0 {
    if i <= 10 {
      continue i + 1, sum + i
      // update new loop state in a functional way
    } else { // Continue with new values
      break sum // Final value when loop completes normally
    }
  }
  inspect(sum_result, content="55")

  // special form with condition and state update in the `for` header
  let sum_result2 : Int = for i = 0, sum = 0; i <= 10; i = i + 1, sum = sum + i {

  } else {
    sum
  }
  inspect(sum_result2, content="55")
}
```

## Label and Optional Parameters

Good example: Use labeled and optional parameters

```mbt
fn g(
  positional : Int,
  required~ : Int,
  optional? : Int,
  optional_with_default? : Int = 42,
) -> String {
  // make sure you understand the types of the arguments really is:
  let _ : Int = positional
  let _ : Int = required
  // let _ : Option[Int] = optional 
  let _ : Int = optional_with_default
  "\{positional},\{required},\{optional},\{optional_with_default}"
}

test {
  inspect(g(1, required=2), content="1,2,None,42")
  inspect(g(1, required=2, optional=3), content="1,2,Some(3),42")
  inspect(g(1, required=4, optional_with_default=100), content="1,4,None,100")
}
```

Misuse: `arg : Type?` is not an optional parameter

```mbt
fn with_config(a : Int?, b : Int?, c : Int) -> String {
  // T? is syntactic sugar for Option[T]
  "\{a},\{b},\{c}"
}

test {
  inspect(with_config(None, None, 1), content="None,None,1")
  inspect(with_config(Some(5), Some(5), 1), content="Some(5),Some(5),1")
}
```

Anti pattern: `arg? : Type?` 

```mbt
// How to fix: declare `(a? : Int, b? : Int = 1)` directly
fn f(a? : Int?, b? : Int? = Some(1)) -> Unit {...}
test {
  // How to fix: call `f(b=2)` directly
  f(a=None, b=Some(2))
}
```

Bad example: `arg : APIOptions`

```mbt
// Do not use struct to group options.
struct APIOptions {
  a : Int?
}

fn not_idiomatic(opts : APIOptions, arg : Int) -> Unit {
  ...
}

test {
  // Hard to use in call site
  not_idiomatic({ a: Some(5) }, 10)
  not_idiomatic({ a: None }, 10)
}
```

## Checked Errors

MoonBit uses **checked** error-throwing functions, not unchecked exceptions,
it is recommended to use `raise` for functions and use `Result` in testing.

```mbt check
///|
///  Declare error types with 'suberror'
suberror ValueError String

///|
struct Position(Int, Int) derive(ToJson, Show, Eq)

///|
pub(all) suberror ParseError {
  InvalidChar(Position, Char)
  InvalidEof
  InvalidNumber(Position, String)
  InvalidIdentEscape(Position)
} derive(Eq, ToJson, Show)

///|
/// Functions declare what they can throw
fn parse_int(s : String) -> Int raise ParseError {
  // 'raise' throws an error
  if s.is_empty() {
    raise ParseError::InvalidEof
  }
  ... // parsing logic
}

///|
fn div(x : Int, y : Int) -> Int raise {
  if y == 0 {
    raise Failure("Division by zero")
  }
  x / y
}

///|
test "inspect raise function" {
  inspect(
    try? div(1, 0),
    content=(
      #|Err(Failure("Division by zero"))
    ),
  ) // Result[Int, MyError]
}

// Three ways to handle errors:

///|
/// Propagate automatically
fn use_parse() -> Int raise ParseError {
  let x = parse_int("123")
  // Error *auto* propagates by default.
  // *unlike* Swift, you don't need mark `try` for functions that can raise errors,
  // compiler infers it automatically. This makes error-handling code cleaner
  // while still being type-safe and explicit about what errors can occur.
  x * 2
}

///|
///  Mark `raise` for all possible errors, don't care what error it is
/// If you are doing a quick prototype, just mark it as raise is good enough.
fn use_parse2() -> Int raise {
  let x = parse_int("123")
  x * 2
}

///|
///  Convert to Result with try?
fn safe_parse(s : String) -> Result[Int, ParseError] {
  let val1 : Result[_] = try? parse_int(s) // Returns Result[Int, ParseError]
  // try! is rarely used - it panics on error, similar to unwrap() in Rust
  // let val2 : Int = try! parse_int(s) // Returns Int otherwise crash

  // Alternative explicit handling:
  let val3 = try parse_int(s) catch {
    err => Err(err)
  } noraise { // noraise block is optional - handles the success case
    v => Ok(v)
  }
  ...
}

///|
///  3. Handle with try-catch
fn handle_parse(s : String) -> Int {
  parse_int(s) catch {
    ParseError::InvalidEof => {
      println("Parse failed: InvalidEof")
      -1 // Default value
    }
    _ => 2
  }
}
```

# Methods and Traits

Methods use `Type::method_name` syntax, traits require explicit implementation:

```mbt check
///|
struct Rectangle {
  width : Double
  height : Double
}

///|
// Methods are prefixed with Type::
fn Rectangle::area(self : Rectangle) -> Double {
  self.width * self.height
}

///|
/// Static methods don't need self
fn Rectangle::new(w : Double, h : Double) -> Rectangle {
  { width: w, height: h }
}

///|
/// Show trait now uses output(self, logger) for custom formatting
/// to_string() is automatically derived from this
pub impl Show for Rectangle with output(self, logger) {
  logger.write_string("Rectangle(\{self.width}x\{self.height})")
}

///|
/// Traits can have non-object-safe methods
trait Named {
  name() -> String // No 'self' parameter - not object-safe
}

///|
/// Trait bounds in generics
fn[T : Show + Named] describe(value : T) -> String {
  "\{T::name()}: \{value.to_string()}"
}

///|
///  Trait implementation
impl Hash for Rectangle with hash_combine(self, hasher) {
  hasher..combine(self.width)..combine(self.height)
}
```

## Operator Overloading

MoonBit supports operator overloading through traits:

```mbt check
///|
struct Vector(Int, Int)

///|
/// Implement arithmetic operators
pub impl Add for Vector with add(self, other) {
  Vector(self.0 + other.0, self.1 + other.1)
}

///|
pub impl Mul for Vector with mul(self, other) {
  Vector(self.0 * other.0, self.1 * other.1)
}

///|
struct Person {
  age : Int
} derive(Eq)

///|
/// Comparison operators
pub impl Compare for Person with compare(self, other) {
  self.age.compare(other.age)
}

///|
test "overloading" {
  let v1 : Vector = Vector(1, 2)
  let v2 : Vector = Vector(3, 4)
  let _v3 : Vector = v1 + v2

}
```

## Access Control Modifiers

MoonBit has fine-grained visibility control:

```mbt check
///|
/// `fn` defaults to Private - only visible in current package
fn internal_helper() -> Unit {
  ...
}

///|
pub fn get_value() -> Int {
  ...
}

///|
// Struct (default) - type visible, implementation hidden
struct DataStructure {}

///|
/// `pub struct` defaults to readonly - can read, pattern match, but not create
pub struct Config {}

///|
///  Public all - full access
pub(all) struct Config2 {}

///|
/// Abstract trait (default) - cannot be implemented by
/// types outside this package
pub trait MyTrait {}

///|
///  Open for extension
pub(open) trait Extendable {}
```

# Best Practices and Reference

## Common Pitfalls to Avoid

1. **Don't use uppercase for variables/functions** - compilation error
2. **Don't forget `mut` for mutable fields** - immutable by default
3. **Don't assume value semantics** - most types pass by reference
4. **Don't ignore error handling** - errors must be explicitly handled
5. **Don't use `return` unnecessarily** - last expression is the return value
6. **Don't create methods without Type:: prefix** - methods need explicit type prefix
7. Don't forget to handle array bounds - use get() for safe access
8. Don't mix up String indexing (returns Int). Use `for char in s {...}` for char iteration
9. Don't forget @package prefix when calling functions from other packages
10. Don't use ++ or -- (not supported), use `i = i + 1` or `i += 1`
11. **Don't add explicit `try` for error-raising functions** - errors propagate automatically (unlike Swift)
12. **Legacy syntax**: Older code may use `function_name!(...)` or `function_name(...)?` - these are deprecated; use normal calls and `try?` for Result conversion

# MoonBit Build System - Essential Guide

## Idiomatic Project Structure

MoonBit projects use `moon.mod.json` (module descriptor) and `moon.pkg.json`
(package descriptor):

```
my_module
├── Agents.md                 # Guide to Agents
├── README.mbt.md             # Markdown with tested code blocks (`test "..." { ... }`)
├── README.md -> README.mbt.md
├── cmd                       # Command line directory
│   └── main
│       ├── main.mbt
│       └── moon.pkg.json     # executable package with {"is_main": true}
├── liba/                     # Library packages
│   └── moon.pkg.json         # Referenced by other packages as `@username/my_module/liba`
│   └── libb/                 # Library packages
│       └── moon.pkg.json     # Referenced by other packages as `@username/my_module/liba/libb`
├── moon.mod.json             # Module metadata, source field(optional) specifies the source directory of the module
├── moon.pkg.json             # Package metadata (each directory is a package like Golang)
├── user_pkg.mbt              # Root packages, referenced by other packages as `@username/my_module`
├── user_pkg_wbtest.mbt       # White-box tests (only needed for testing internal private members, similar to Golang's package mypackage)
└── user_pkg_test.mbt         # Black-box tests
└── ...                       # More package files, symbols visible to current package (like Golang)
```

## Essential Commands

- `moon new my_project` - Create new project
- `moon run cmd/main` - Run main package
- `moon build` - Build project
- `moon check` - Type check without building, use it regularly
- `moon check --target all` - Type check for all backends
- `moon add package` - Add dependency
- `moon remove package` - Remove dependency
- `moon fmt` - Format code

### Test Commands

- `moon test` - Run all tests
- `moon test --update`
- `moon test -v` - Verbose output with test names
- `moon test dirname` - Test specific directory
- `moon test filename` - Test specific file in a directory
- `moon coverage analyze` - Analyze coverage

## Package Management

### Adding Dependencies

```bash
moon add moonbitlang/x        # Add latest version
moon add moonbitlang/x@0.4.6  # Add specific version
```

### Updating Dependencies

```bash
moon update                   # Update package index
```

## Key Configuration

### Module (`moon.mod.json`)

```json
{
  "name": "username/hello", // Required format for published modules
  "version": "0.1.0",
  "source": ".", // Source directory(optional, default: ".")
  "repository": "", // Git repository URL
  "keywords": [], // Search keywords
  "description": "...", // Module description
  "deps": {
    // Dependencies from mooncakes.io, using`moon add` to add dependencies
    "moonbitlang/x": "0.4.6"
  }
}
```

### Package (`moon.pkg.json`)

```json
{
  "is_main": true,                 // Creates executable when true
  "import": [                      // Package dependencies
    "username/hello/liba",         // Simple import, use @liba.foo() to call functions
    {
      "path": "moonbitlang/x/encoding",
      "alias": "libb"              // Custom alias, use @libb.encode() to call functions
    }
  ],
  "test-import": [...],            // Imports for black-box tests, similar to import
  "wbtest-import": [...]           // Imports for white-box tests, similar to import (rarely used)
}
```

Packages per directory, packages without `moon.pkg.json` are not recognized.

## Package Importing (used in moon.pkg.json)

- **Import format**: `"module_name/package_path"`
- **Usage**: `@alias.function()` to call imported functions
- **Default alias**: Last part of path (e.g., `liba` for `username/hello/liba`)
- **Package reference**: Use `@packagename` in test files to reference the
  tested package

**Package Alias Rules**:

- Import `"username/hello/liba"` → use `@liba.function()` (default alias is last path segment)
- Import with custom alias `{"path": "moonbitlang/x/encoding", "alias": "enc"}` → use `@enc.function()`
- In `_test.mbt` or `_wbtest.mbt` files, the package being tested is auto-imported

Example:

```mbt
///|
/// In main.mbt after importing "username/hello/liba" in `moon.pkg.json`
fn main {
  println(@liba.hello()) // Calls hello() from liba package
}
```

## Using Standard Library (moonbitlang/core)

**MoonBit standard library (moonbitlang/core) packages are automatically imported** - DO NOT add them to dependencies:

- ❌ **DO NOT** use `moon add` to add standard library packages like `moonbitlang/core/strconv`
- ❌ **DO NOT** add standard library packages to `"deps"` field of `moon.mod.json`
- ❌ **DO NOT** add standard library packages to `"import"` field of `moon.pkg.json`
- ✅ **DO** use them directly: `@strconv.parse_int()`, `@list.List`, `@array.fold()`, etc.

If you get an error like "cannot import `moonbitlang/core/strconv`", remove it from imports - it's automatically available.

## Creating Packages

To add a new package `fib` under `.`:

1. Create directory: `./fib/`
2. Add `./fib/moon.pkg.json`: `{}` -- Minimal valid moon.pkg.json
3. Add `.mbt` files with your code
4. Import in dependent packages:

   ```json
   {
     "import": [
        "username/hello/fib",
        ...
     ]
   }
   ```

## Conditional Compilation

Target specific backends/modes in `moon.pkg.json`:

```json
{
  "targets": {
    "wasm_only.mbt": ["wasm"],
    "js_only.mbt": ["js"],
    "debug_only.mbt": ["debug"],
    "wasm_or_js.mbt": ["wasm", "js"], // for wasm or js backend
    "not_js.mbt": ["not", "js"], // for nonjs backend
    "complex.mbt": ["or", ["and", "wasm", "release"], ["and", "js", "debug"]] // more complex conditions
  }
}
```

**Available conditions:**

- **Backends**: `"wasm"`, `"wasm-gc"`, `"js"`, `"native"`
- **Build modes**: `"debug"`, `"release"`
- **Logical operators**: `"and"`, `"or"`, `"not"`

## Link Configuration

### Basic Linking

```json
{
  "link": true, // Enable linking for this package
  // OR for advanced cases:
  "link": {
    "wasm": {
      "exports": ["hello", "foo:bar"], // Export functions
      "heap-start-address": 1024, // Memory layout
      "import-memory": {
        // Import external memory
        "module": "env",
        "name": "memory"
      },
      "export-memory-name": "memory" // Export memory with name
    },
    "wasm-gc": {
      "exports": ["hello"],
      "use-js-builtin-string": true, // JS String Builtin support
      "imported-string-constants": "_" // String namespace
    },
    "js": {
      "exports": ["hello"],
      "format": "esm" // "esm", "cjs", or "iife"
    },
    "native": {
      "cc": "gcc", // C compiler
      "cc-flags": "-O2 -DMOONBIT", // Compile flags
      "cc-link-flags": "-s" // Link flags
    }
  }
}
```

## Warning Control

Disable specific warnings in `moon.mod.json` or `moon.pkg.json`:

```json
{
  "warn-list": "-2-29" // Disable unused variable (2) & unused package (29)
}
```

**Common warning numbers:**

- `1` - Unused function
- `2` - Unused variable
- `11` - Partial pattern matching
- `12` - Unreachable code
- `29` - Unused package

Use `moonc build-package -warn-help` to see all available warnings.

## Pre-build Commands

Embed external files as MoonBit code:

```json
{
  "pre-build": [
    {
      "input": "data.txt",
      "output": "embedded.mbt",
      "command": ":embed -i $input -o $output --name data --text"
    },
    ... // more embed commands
  ]
}
```

Generated code example:

```mbt check
///|
let data : String =
  #|hello,
  #|world
  #|
```

# Documentation

Write documentation using `///` comments (started with `///|` to delimit the
block code)

```mbt check
///|
/// Get the largest element of a non-empty `Array`.
///
/// # Example
/// ```mbt check
/// test {
///  inspect(sum_array([1, 2, 3, 4, 5, 6]), content="21")
/// }
/// ```
///
/// # Panics
/// Panics if the `xs` is empty.
pub fn sum_array(xs : Array[Int]) -> Int {
  xs.fold(init=0, (a, b) => a + b)
}
```

The MoonBit code in docstring will be type checked and tested automatically.
(using `moon test --update`)

# Development Workflow

## MoonBit Tips

- MoonBit code is organized in files/block style.
  A package is composed of a list of files, their order does not matter,
  keep them separate so that it is easy to focus on critical parts.

  Each block is separated by `///|`, the order of each block is irrelevant too. You can process
  block by block independently.

  You are encouraged to generate code in a block-by-block manner.

  You are encouraged to search and replace block by block instead of
  replacing the whole file.

  You are encouraged to keep each file focused.

- SPLIT the large file into small files, the order does not matter.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

- `moon fmt` is used to format your code properly.

- `moon info` is used to update the generated interface of the package
  **in current project**. Each package has a generated interface file `.mbti`,
  it is a brief formal description of the package. If nothing in `.mbti`
  changes, this means your change does not bring the visible changes to the
  external package users, it is typically a safe refactoring.
  **Note**: `moon info` will only work with packages in the current project, and
  therefore you cannot use `moon info` to generate interface for dependencies
  like standard library.

- So in the last step, you typically run `moon info && moon fmt` to update the
  interface and format the code. You also check the diffs of `.mbti` file to see
  if the changes are expected.

- You should run `moon test` to check the test is passed. MoonBit supports
  snapshot testing, so in some cases, your changes indeed change the behavior of
  the code, you should run `moon test --update` to update the snapshot.

- You can run `moon check` to check the code is linted correctly, run it
  regularly to ensure you are not in a messy state.

- MoonBit packages are organized per directory; each directory has a
  `moon.pkg.json` listing its dependencies. Each package has its files and
  blackbox test files (common, ending in `_test.mbt`) and whitebox test files
  (ending in `_wbtest.mbt`).

- In the toplevel directory, there is a `moon.mod.json` file describing the
  module and metadata.

## MoonBit Package `README` Generation Guide

- Output `README.mbt.md` in the package directory. 
  `*.mbt.md` file and docstring contents treats `mbt check` specially.
  `mbt check` block will be included directly as code and also run by `moon check` and `moon test`. 
  In docstrings, `mbt check` should only contain test blocks.
  If you are only referencing types from the package, you should use `mbt` which will only be syntax highlighted.
  Symlink `README.mbt.md` to `README.md` to adapt to systems that expect `README.md`. 
- Aim to cover ≥90% of the public API with concise sections and examples.
- Organize by feature: construction, consumption, transformation, and key usage tips.

## MoonBit Testing Guide

Practical testing guidance for MoonBit. Keep tests black-box by default and rely on snapshot `inspect(...)`.

- Black-box by default: Call only public APIs via `@package.fn`. Use white-box tests only when private members matter.
- **Snapshots**: Prefer `inspect(value, content="...")`. If unknown, write `inspect(value)` and run `moon test --update` (or `moon test -u`).
  - Use regular `inspect()` for simple values (uses `Show` trait)
  - Use `@json.inspect()` for complex nested structures (uses `ToJson` trait, produces more readable output)
  - It is encouraged to `inspect` or `@json.inspect` the whole return value of a function if
    the whole return value is not huge, this makes test simple. You need `impl (Show|ToJson) for YourType` or `derive (Show, ToJson)`.
- **Update workflow**: After changing code that affects output, run `moon test --update` to regenerate snapshots, then review the diffs in your test files (the `content=` parameter will be updated automatically).
- Grouping: Combine related checks in one `test "..." { ... }` block for speed and clarity.
- Panics: Name test with prefix `test "panic ..." {...}`; if the call returns a value, wrap it with `ignore(...)` to silence warnings.
- Errors: Use `try? f()` to get `Result[...]` and `inspect` it when a function may raise.
- Verify: Run `moon test` (or `-u` to update snapshots) and `moon fmt` afterwards.

## Spec-driven Development

- The spec can be written in a readonly `spec.mbt` file (name is conventional, not mandatory) with stub code marked as declarations:

```mbt check
#declaration_only
pub type Yaml
#declaration_only
pub fn Yaml::to_string(y : Yaml) -> String raise {...}
#declaration_only
pub fn parse_yaml(s : String) -> Yaml raise {...}
```
- Add `spec_easy_test.mbt`, `spec_difficult_test.mbt` etc to test the spec functions; everything will be type-checked.
- The AI or students can implement the `declaration_only` functions in different files thanks to our package organization.
- Run `moon test` to check everything is correct.

- `#declaration_only` is supported for functions, methods, and types.
- The `pub type Yaml` line is an intentionally opaque placeholder; the implementer chooses its representation.
- Note the spec file can also contain normal code, not just declarations.

# Semantics based CLI tools

## API Discovery with `moon doc`

**CRITICAL**: `moon doc '<query>'` is your PRIMARY tool for discovering available APIs, functions, types, and methods in MoonBit. It is **more powerful and accurate** than `grep_search`, `semantic_search`, or any file-based searching tools. Always prefer `moon doc` over other approaches when exploring what APIs are available.

### Query Syntax

`moon doc` uses a specialized query syntax designed for symbol lookup:
- **Empty query**: `moon doc `

  - In a module: shows all available packages in current module
  - In a package: shows all symbols in current package
  - Outside package: shows all available packages

- **Function/value lookup**: `moon doc "[@pkg.]sym"`
  
- **Type lookup**: `moon doc "[@pkg.]Sym"`

- **Method/field lookup**: `moon doc "[@pkg.]T::sym"`

- **Package exploration**: `moon doc "@pkg"`
  - Show package `pkg` and list all its exported symbols
  - Example: `moon doc "@json"` - explore entire `@json` package
  - Example: `moon doc "@encoding/utf8"` - explore nested package

### Workflow for API Discovery

1. **Finding functions**: Use `moon doc "@pkg.function_name"` before grep searching
2. **Exploring packages**: Use `moon doc "@pkg"` to see what's available in a package
3. **Method discovery**: Use `moon doc "Type::method"` to find methods on types
4. **Type inspection**: Use `moon doc "TypeName"` to see type definition and methods
5. **Package exploration**: Use `moon doc ""` at module root to see all available packages, including dependencies and stdlib
6. **Globbing**: Use `*` wildcard for partial matches, e.g. `moon doc "String::*rev*"` to find all String methods with "rev" in their name
### Examples

````bash
# search for String methods in standard library:
$ moon doc "String"

type String

  pub fn String::add(String, String) -> String
  pub fn String::at(String, Int) -> Int
  # ... more methods omitted ...

# list all symbols in a standard library package:
$ moon doc "@buffer"
moonbitlang/core/buffer

fn from_array(ArrayView[Byte]) -> Buffer
fn from_bytes(Bytes) -> Buffer
# ... more functions omitted ...

# list the specific function in a package:
$ moon doc "@buffer.new"
package "moonbitlang/core/buffer"

pub fn new(size_hint? : Int) -> Buffer
  Creates a new extensible buffer with specified initial capacity. If the
   initial capacity is less than 1, the buffer will be initialized with capacity
   1.
# ... more details omitted ...

$ moon doc "String::*rev*"  
package "moonbitlang/core/string"

pub fn String::rev(String) -> String
  Returns a new string with the characters in reverse order. It respects
   Unicode characters and surrogate pairs but not grapheme clusters.

pub fn String::rev_find(String, StringView) -> Int?
  Returns the offset (charcode index) of the last occurrence of the given
   substring. If the substring is not found, it returns None.

# ... more details omitted ...

**Best practice**: When implementing a feature, start with `moon doc` queries to discover available APIs before writing code. This is faster and more accurate than searching through files.

````

## `moon ide peek-def` for Definition Lookup

Use this when you want inline context for a symbol without jumping files.

``` file src/parse.mbt
L45:|///|
L46:|fn Parser::read_u32_leb128(self : Parser) -> UInt raise ParseError {
L47:|  ...
...:| }
```

```bash
$ moon ide peek-def -symbol Parser -loc src/parse.mbt:46:4
Definition found at file src/parse.mbt
  | ///|
2 | priv struct Parser {
  |             ^^^^^^
  |   bytes : Bytes
  |   mut pos : Int
  | }
  | 
  | ///|
  | fn Parser::new(bytes : Bytes) -> Parser {
  |   { bytes, pos: 0 }
  | }
  | 
  | ///|
  | fn Parser::eof(self : Parser) -> Bool {
  |   self.pos >= self.bytes.length()
  | }
  | 
```
For the `-loc` argument, the line number must be precise; the column can be approximate since `-symbol` helps locate the position.