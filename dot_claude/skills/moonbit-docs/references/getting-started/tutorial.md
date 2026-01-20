---
title: "MoonBit's Build System Tutorial — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/toolchain/moon/tutorial.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/toolchain/moon/tutorial.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Ftoolchain/moon/tutorial.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/toolchain/moon/tutorial.md "Download source file")
* .pdf

# MoonBit's Build System Tutorial

## Contents

# MoonBit's Build System Tutorial[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#moonbit-s-build-system-tutorial "Link to this heading")

Moon is the build system for the MoonBit language, currently based on the [n2](https://github.com/evmar/n2) project. Moon supports parallel and incremental builds. Additionally, moon also supports managing and building third-party packages on [mooncakes.io](https://mooncakes.io/)

## Prerequisites[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#prerequisites "Link to this heading")

Before you begin with this tutorial, make sure you have installed the following:

1. **MoonBit CLI Tools**: Download it from the <https://www.moonbitlang.com/download/>. This command line tool is needed for creating and managing MoonBit projects.

   Use `moon help` to view the usage instructions.

   ```
   $ moon help
   ...
   ```
2. **MoonBit Language** plugin in Visual Studio Code: You can install it from the VS Code marketplace. This plugin provides a rich development environment for MoonBit, including functionalities like syntax highlighting, code completion, and more.

Once you have these prerequisites fulfilled, let's start by creating a new MoonBit module.

## Creating a New Module[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#creating-a-new-module "Link to this heading")

To create a new module, enter the `moon new <path>` command in the terminal, where the path is the directory that you'd like to put the project, and you will see the module being created. By using all the default values, you can create a new module named `username/my_project` in the `my_project` directory.

```
$ moon new my_project
Initialized empty Git repository in my_project/.git/
Created username/my_project at my_project
```

You may also specify the username and module name by using the `--user` option and `--name` option respectively.
If you have logged-in, the username will default to your username.

## Understanding the Module Directory Structure[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#understanding-the-module-directory-structure "Link to this heading")

After creating the new module, your directory structure should resemble the following:

```
my_project
├── Agents.md
├── cmd
│   └── main
│       ├── main.mbt
│       └── moon.pkg.json
├── LICENSE
├── moon.mod.json
├── moon.pkg.json
├── my_project_test.mbt
├── my_project.mbt
├── README.mbt.md
└── README.md -> README.mbt.md
```

Note

On Windows system, you need administrator priviledge or the developer mode enabled to create the symbolic link.

Here's a brief explanation of the directory structure:

* `moon.mod.json` is used to identify a directory as a MoonBit module. It contains the module's metadata, such as the module name, version, etc.

  ```
  {
    "name": "username/my_project",
    "version": "0.1.0",
    "readme": "README.md",
    "repository": "",
    "license": "Apache-2.0",
    "keywords": [],
    "description": ""
  }
  ```
* `.` and `cmd/main` directories: These are the packages within the module. Each package can contain multiple `.mbt` files, which are the source code files for the MoonBit language. However, regardless of how many `.mbt` files a package has, they all share a common `moon.pkg.json` file. `*_test.mbt` are separate test files in the package, these files are for blackbox test, so private members of the same package cannot be accessed directly.
* `moon.pkg.json` is package descriptor. It defines the properties of the package, such as whether it is the main package and the packages it imports.

  + `cmd/main/moon.pkg.json`:

    ```
    {
      "is-main": true,
      "import": [
        {
          "path": "username/my_project",
          "alias": "lib"
        }
      ]
    }
    ```

    Here, `"is-main: true"` declares that the package contains an entry for the `moon run` command.
  + `moon.pkg.json`:

    ```
    {}
    ```

    This file is empty. Its purpose is simply to inform the build system that this folder is a package.
* `README.mbt.md` is the README file. The code blocks written inside will be type checked and tested by `moon check` and `moon test`.

## Working with Packages[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#working-with-packages "Link to this heading")

Our `username/my_project` module contains two packages: `username/my_project` and `username/my_project/cmd/main`.

The `username/my_project` package contains `my_project.mbt` and `my_project_test.mbt` files:

my\_project.mbt[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#id1 "Link to this code")

```
///|
pub fn fib(n : Int) -> Int64 {
  for i = 0, a = 0L, b = 1L; i < n; i = i + 1, a = b, b = a + b {

  } else {
    b
  }
}
```

my\_project\_test.mbt[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#id2 "Link to this code")

```
///|
test "fib" {
  let array = [1, 2, 3, 4, 5].map(fib(_))

  // `inspect` is used to check the output of the function
  // Just write `inspect(value)` and execute `moon test --update`
  // to update the expected output, and verify them afterwards
  inspect(array, content="[1, 2, 3, 5, 8]")
}
```

Note

The generated file name will depend on the package name.

The `username/my_project/cmd/main` package contains a `main.mbt` file:

```
///|
fn main {
  println(@lib.fib(10))
}
```

To execute the program, specify the file system's path to the `username/my_project/cmd/main` package in the `moon run` command:

```
$ moon run cmd/main
89
```

You can test using the `moon test` command:

```
$ moon test
Total tests: 1, passed: 1, failed: 0.
```

## Package Importing[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#package-importing "Link to this heading")

In the MoonBit's build system, the dependency is declared at the package level.
To import the `username/my_project` package in `username/my_project/cmd/main`, you need to specify it in `cmd/main/moon.pkg.json`:

```
{
  "is-main": true,
  "import": [
    {
      "path": "username/my_project",
      "alias": "lib"
    }
  ]
}
```

Here, `"username/my_project` specifies importing the root package and having an alias of `lib`, so you can use `@lib.fib(10)` in `cmd/main/main.mbt`.

## Creating and Using a New Package[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#creating-and-using-a-new-package "Link to this heading")

First, create a new directory named `fib` under `lib`:

```
mkdir fib
```

Now, you can create new files under `fib`:

slow.mbt[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#id3 "Link to this code")

```
pub fn fib_slow(n : Int) -> Int {
  match n {
    0 => 0
    1 => 1
    _ => fib_slow(n - 1) + fib_slow(n - 2)
  }
}
```

fast.mbt[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#id4 "Link to this code")

```
pub fn fib_fast(num : Int) -> Int {
  fn aux(n, acc1, acc2) {
    match n {
      0 => acc1
      1 => acc2
      _ => aux(n - 1, acc2, acc1 + acc2)
    }
  }

  aux(num, 0, 1)
}
```

moon.pkg.json[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#id5 "Link to this code")

```
{}
```

After creating these files, your directory structure should look like this:

```
.
├── Agents.md
├── cmd
│   └── main
│       ├── main.mbt
│       └── moon.pkg.json
├── fib
│   ├── fast.mbt
│   ├── moon.pkg.json
│   └── slow.mbt
├── LICENSE
├── moon.mod.json
├── moon.pkg.json
├── my_project_test.mbt
├── my_project.mbt
├── README.mbt.md
└── README.md -> README.mbt.md
```

In the `cmd/main/moon.pkg.json` file, import the `username/my_project/fib` package and customize its alias to `my_awesome_fibonacci`:

```
{
  "is_main": true,
  "import": [
    {
      "path": "username/my_project/fib",
      "alias": "my_awesome_fibonacci"
    }
  ]
}
```

This imports the `fib` package. After doing this, you can use the `fib` package in `cmd/main/main.mbt`. Replace the file content of `cmd/main/main.mbt` to:

```
fn main {
  let a = @my_awesome_fibonacci.fib_slow(10)
  let b = @my_awesome_fibonacci.fib_fast(11)
  println("fib(10) = \{a}, fib(11) = \{b}")
}
```

To execute your program, specify the path to the `main` package:

```
$ moon run cmd/main
fib(10) = 55, fib(11) = 89
```

## Adding Tests[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/tutorial.html#adding-tests "Link to this heading")

Let's add some tests to verify our fib implementation. Add the following content in `fib/fib_test.mbt`:

```
test {
  inspect(fib_slow(0))
  inspect(fib_slow(1))
  inspect(fib_slow(2))
}
```

This code tests the first three terms of the Fibonacci sequence. `test { ... }` defines an inline test block. The code inside an inline test block is executed in test mode.

Inline test blocks are discarded in non-test compilation modes (`moon build` and `moon run`), so they won't cause the generated code size to bloat.

Here we are using the snapshot test. Execute `moon test --update`, and the file should be changed to:

```
test {
  inspect(@fib.fib_slow(0), content="0")
  inspect(@fib.fib_slow(1), content="1")
  inspect(@fib.fib_slow(2), content="1")
}
```

Notice that the test code uses `@fib` to refer to the `fib` package. The build system automatically creates a new package for blackbox tests by using the files that end with `_test.mbt`.

Finally, reuse the `moon test` command, which scans the entire project, identifies, and runs all the tests.
If everything is normal, you will see:

```
$ moon test
Total tests: 2, passed: 2, failed: 0.
```

Contents
