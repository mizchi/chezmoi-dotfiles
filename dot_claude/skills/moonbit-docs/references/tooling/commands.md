---
title: "Command-Line Help for moon — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/toolchain/moon/commands"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/toolchain/moon/commands.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/toolchain/moon/commands.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Ftoolchain/moon/commands.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/toolchain/moon/commands.md "Download source file")
* .pdf

# Command-Line Help for moon

## Contents

# Command-Line Help for `moon`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#command-line-help-for-moon "Link to this heading")

This document contains the help content for the `moon` command-line program.

Hint

For the up-to-date manual, please check out [moon's repository](https://github.com/moonbitlang/moon/blob/main/docs/manual/src/commands.md)

**Command Overview:**

* [`moon`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon)
* [`moon new`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-new)
* [`moon build`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-build)
* [`moon check`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-check)
* [`moon run`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-run)
* [`moon test`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-test)
* [`moon clean`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-clean)
* [`moon fmt`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-fmt)
* [`moon doc`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-doc)
* [`moon info`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-info)
* [`moon bench`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-bench)
* [`moon add`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-add)
* [`moon remove`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-remove)
* [`moon install`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-install)
* [`moon tree`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-tree)
* [`moon login`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-login)
* [`moon register`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-register)
* [`moon publish`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-publish)
* [`moon package`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-package)
* [`moon update`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-update)
* [`moon coverage`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-coverage)
* [`moon coverage analyze`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-coverage-analyze)
* [`moon coverage report`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-coverage-report)
* [`moon coverage clean`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-coverage-clean)
* [`moon generate-build-matrix`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-generate-build-matrix)
* [`moon upgrade`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-upgrade)
* [`moon shell-completion`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-shell-completion)
* [`moon version`↴](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-version)

## `moon`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon "Link to this heading")

**Usage:** `moon <COMMAND>`

**Subcommands:**

* `new` — Create a new MoonBit module
* `build` — Build the current package
* `check` — Check the current package, but don't build object files
* `run` — Run a main package
* `test` — Test the current package
* `clean` — Remove the target directory
* `fmt` — Format source code
* `doc` — Generate documentation
* `info` — Generate public interface (`.mbti`) files for all packages in the module
* `bench` — Run benchmarks in the current package
* `add` — Add a dependency
* `remove` — Remove a dependency
* `install` — Install dependencies
* `tree` — Display the dependency tree
* `login` — Log in to your account
* `register` — Register an account at mooncakes.io
* `publish` — Publish the current module
* `package` — Package the current module
* `update` — Update the package registry index
* `coverage` — Code coverage utilities
* `generate-build-matrix` — Generate build matrix for benchmarking (legacy feature)
* `upgrade` — Upgrade toolchains
* `shell-completion` — Generate shell completion for bash/elvish/fish/pwsh/zsh to stdout
* `version` — Print version information and exit

## `moon new`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-new "Link to this heading")

Create a new MoonBit module

**Usage:** `moon new [OPTIONS] <PATH>`

**Arguments:**

* `<PATH>` — The path of the new project

**Options:**

* `--user <USER>` — The username of the module. Default to the logged-in username
* `--name <NAME>` — The name of the module. Default to the last part of the path

## `moon build`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-build "Link to this heading")

Build the current package

**Usage:** `moon build [OPTIONS]`

**Options:**

* `--std` — Enable the standard library (default)
* `--nostd` — Disable the standard library
* `-g`, `--debug` — Emit debug information
* `--release` — Compile in release mode
* `--strip` — Enable stripping debug information
* `--no-strip` — Disable stripping debug information
* `--target <TARGET>` — Select output target

  Possible values: `wasm`, `wasm-gc`, `js`, `native`, `llvm`, `all`
* `--enable-coverage` — Enable coverage instrumentation
* `--sort-input` — Sort input files
* `--output-wat` — Output WAT instead of WASM
* `-d`, `--deny-warn` — Treat all warnings as errors
* `--no-render` — Don't render diagnostics from moonc (don't pass '-error-format json' to moonc)
* `--warn-list <WARN_LIST>` — Warn list config
* `--alert-list <ALERT_LIST>` — Alert list config
* `-j`, `--jobs <JOBS>` — Set the max number of jobs to run in parallel
* `--render-no-loc <MIN_LEVEL>` — Render no-location diagnostics starting from a certain level

  Default value: `error`

  Possible values: `info`, `warn`, `error`
* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date
* `-w`, `--watch` — Monitor the file system and automatically build artifacts

## `moon check`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-check "Link to this heading")

Check the current package, but don't build object files

**Usage:** `moon check [OPTIONS] [SINGLE_FILE]`

**Arguments:**

* `<SINGLE_FILE>` — Check single file (.mbt or .mbt.md)

**Options:**

* `--std` — Enable the standard library (default)
* `--nostd` — Disable the standard library
* `-g`, `--debug` — Emit debug information
* `--release` — Compile in release mode
* `--strip` — Enable stripping debug information
* `--no-strip` — Disable stripping debug information
* `--target <TARGET>` — Select output target

  Possible values: `wasm`, `wasm-gc`, `js`, `native`, `llvm`, `all`
* `--enable-coverage` — Enable coverage instrumentation
* `--sort-input` — Sort input files
* `--output-wat` — Output WAT instead of WASM
* `-d`, `--deny-warn` — Treat all warnings as errors
* `--no-render` — Don't render diagnostics from moonc (don't pass '-error-format json' to moonc)
* `--warn-list <WARN_LIST>` — Warn list config
* `--alert-list <ALERT_LIST>` — Alert list config
* `-j`, `--jobs <JOBS>` — Set the max number of jobs to run in parallel
* `--render-no-loc <MIN_LEVEL>` — Render no-location diagnostics starting from a certain level

  Default value: `error`

  Possible values: `info`, `warn`, `error`
* `--output-json` — Output in json format
* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date
* `-w`, `--watch` — Monitor the file system and automatically check files
* `-p`, `--package-path <PACKAGE_PATH>` — The package(and it's deps) to check
* `--patch-file <PATCH_FILE>` — The patch file to check, Only valid when checking specified package
* `--no-mi` — Whether to skip the mi generation, Only valid when checking specified package
* `--explain` — Whether to explain the error code with details

## `moon run`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-run "Link to this heading")

Run a main package

**Usage:** `moon run [OPTIONS] <PACKAGE_OR_MBT_FILE> [ARGS]...`

**Arguments:**

* `<PACKAGE_OR_MBT_FILE>` — The package or .mbt file to run
* `<ARGS>` — The arguments provided to the program to be run

**Options:**

* `--std` — Enable the standard library (default)
* `--nostd` — Disable the standard library
* `-g`, `--debug` — Emit debug information
* `--release` — Compile in release mode
* `--strip` — Enable stripping debug information
* `--no-strip` — Disable stripping debug information
* `--target <TARGET>` — Select output target

  Possible values: `wasm`, `wasm-gc`, `js`, `native`, `llvm`, `all`
* `--enable-coverage` — Enable coverage instrumentation
* `--sort-input` — Sort input files
* `--output-wat` — Output WAT instead of WASM
* `-d`, `--deny-warn` — Treat all warnings as errors
* `--no-render` — Don't render diagnostics from moonc (don't pass '-error-format json' to moonc)
* `--warn-list <WARN_LIST>` — Warn list config
* `--alert-list <ALERT_LIST>` — Alert list config
* `-j`, `--jobs <JOBS>` — Set the max number of jobs to run in parallel
* `--render-no-loc <MIN_LEVEL>` — Render no-location diagnostics starting from a certain level

  Default value: `error`

  Possible values: `info`, `warn`, `error`
* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date
* `--build-only` — Only build, do not run the code

## `moon test`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-test "Link to this heading")

Test the current package

**Usage:** `moon test [OPTIONS] [SINGLE_FILE]`

**Arguments:**

* `<SINGLE_FILE>` — Run test in single file (.mbt or .mbt.md)

**Options:**

* `--std` — Enable the standard library (default)
* `--nostd` — Disable the standard library
* `-g`, `--debug` — Emit debug information
* `--release` — Compile in release mode
* `--strip` — Enable stripping debug information
* `--no-strip` — Disable stripping debug information
* `--target <TARGET>` — Select output target

  Possible values: `wasm`, `wasm-gc`, `js`, `native`, `llvm`, `all`
* `--enable-coverage` — Enable coverage instrumentation
* `--sort-input` — Sort input files
* `--output-wat` — Output WAT instead of WASM
* `-d`, `--deny-warn` — Treat all warnings as errors
* `--no-render` — Don't render diagnostics from moonc (don't pass '-error-format json' to moonc)
* `--warn-list <WARN_LIST>` — Warn list config
* `--alert-list <ALERT_LIST>` — Alert list config
* `-j`, `--jobs <JOBS>` — Set the max number of jobs to run in parallel
* `--render-no-loc <MIN_LEVEL>` — Render no-location diagnostics starting from a certain level

  Default value: `error`

  Possible values: `info`, `warn`, `error`
* `-p`, `--package <PACKAGE>` — Run test in the specified package
* `-f`, `--file <FILE>` — Run test in the specified file. Only valid when `--package` is also specified
* `-i`, `--index <INDEX>` — Run only the index-th test in the file. Only valid when `--file` is also specified
* `--doc-index <DOC_INDEX>` — Run only the index-th doc test in the file. Only valid when `--file` is also specified
* `-u`, `--update` — Update the test snapshot
* `-l`, `--limit <LIMIT>` — Limit of expect test update passes to run, in order to avoid infinite loops

  Default value: `256`
* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date
* `--build-only` — Only build, do not run the tests
* `--no-parallelize` — Run the tests in a target backend sequentially
* `--test-failure-json` — Print failure message in JSON format
* `--patch-file <PATCH_FILE>` — Path to the patch file
* `--doc` — Run doc test

## `moon clean`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-clean "Link to this heading")

Remove the target directory

**Usage:** `moon clean`

## `moon fmt`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-fmt "Link to this heading")

Format source code

**Usage:** `moon fmt [OPTIONS] [ARGS]...`

**Arguments:**

* `<ARGS>`

**Options:**

* `--check` — Check only and don't change the source code
* `--sort-input` — Sort input files
* `--block-style <BLOCK_STYLE>` — Add separator between each segments

  Possible values: `false`, `true`

## `moon doc`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-doc "Link to this heading")

Generate documentation

**Usage:** `moon doc [OPTIONS]`

**Options:**

* `--serve` — Start a web server to serve the documentation
* `-b`, `--bind <BIND>` — The address of the server

  Default value: `127.0.0.1`
* `-p`, `--port <PORT>` — The port of the server

  Default value: `3000`
* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date

## `moon info`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-info "Link to this heading")

Generate public interface (`.mbti`) files for all packages in the module

**Usage:** `moon info [OPTIONS]`

**Options:**

* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date
* `--no-alias` — Do not use alias to shorten package names in the output
* `--target <TARGET>` — Select output target

  Possible values: `wasm`, `wasm-gc`, `js`, `native`, `llvm`, `all`
* `-p`, `--package <PACKAGE>` — only emit mbti files for the specified package

## `moon bench`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-bench "Link to this heading")

Run benchmarks in the current package

**Usage:** `moon bench [OPTIONS]`

**Options:**

* `--std` — Enable the standard library (default)
* `--nostd` — Disable the standard library
* `-g`, `--debug` — Emit debug information
* `--release` — Compile in release mode
* `--strip` — Enable stripping debug information
* `--no-strip` — Disable stripping debug information
* `--target <TARGET>` — Select output target

  Possible values: `wasm`, `wasm-gc`, `js`, `native`, `llvm`, `all`
* `--enable-coverage` — Enable coverage instrumentation
* `--sort-input` — Sort input files
* `--output-wat` — Output WAT instead of WASM
* `-d`, `--deny-warn` — Treat all warnings as errors
* `--no-render` — Don't render diagnostics from moonc (don't pass '-error-format json' to moonc)
* `--warn-list <WARN_LIST>` — Warn list config
* `--alert-list <ALERT_LIST>` — Alert list config
* `-j`, `--jobs <JOBS>` — Set the max number of jobs to run in parallel
* `--render-no-loc <MIN_LEVEL>` — Render no-location diagnostics starting from a certain level

  Default value: `error`

  Possible values: `info`, `warn`, `error`
* `-p`, `--package <PACKAGE>` — Run test in the specified package
* `-f`, `--file <FILE>` — Run test in the specified file. Only valid when `--package` is also specified
* `-i`, `--index <INDEX>` — Run only the index-th test in the file. Only valid when `--file` is also specified
* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date
* `--build-only` — Only build, do not bench
* `--no-parallelize` — Run the benchmarks in a target backend sequentially

## `moon add`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-add "Link to this heading")

Add a dependency

**Usage:** `moon add [OPTIONS] <PACKAGE_PATH>`

**Arguments:**

* `<PACKAGE_PATH>` — The package path to add

**Options:**

* `--bin` — Whether to add the dependency as a binary

## `moon remove`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-remove "Link to this heading")

Remove a dependency

**Usage:** `moon remove <PACKAGE_PATH>`

**Arguments:**

* `<PACKAGE_PATH>` — The package path to remove

## `moon install`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-install "Link to this heading")

Install dependencies

**Usage:** `moon install`

## `moon tree`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-tree "Link to this heading")

Display the dependency tree

**Usage:** `moon tree`

## `moon login`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-login "Link to this heading")

Log in to your account

**Usage:** `moon login`

## `moon register`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-register "Link to this heading")

Register an account at mooncakes.io

**Usage:** `moon register`

## `moon publish`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-publish "Link to this heading")

Publish the current module

**Usage:** `moon publish [OPTIONS]`

**Options:**

* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date

## `moon package`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-package "Link to this heading")

Package the current module

**Usage:** `moon package [OPTIONS]`

**Options:**

* `--frozen` — Do not sync dependencies, assuming local dependencies are up-to-date
* `--list`

## `moon update`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-update "Link to this heading")

Update the package registry index

**Usage:** `moon update`

## `moon coverage`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-coverage "Link to this heading")

Code coverage utilities

**Usage:** `moon coverage <COMMAND>`

**Subcommands:**

* `analyze` — Run test with instrumentation and report coverage
* `report` — Generate code coverage report
* `clean` — Clean up coverage artifacts

## `moon coverage analyze`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-coverage-analyze "Link to this heading")

Run test with instrumentation and report coverage

**Usage:** `moon coverage analyze [OPTIONS] [-- <EXTRA_FLAGS>...]`

**Arguments:**

* `<EXTRA_FLAGS>` — Extra flags passed directly to `moon_cove_report`

**Options:**

* `-p`, `--package <PACKAGE>` — Analyze coverage for a specific package

## `moon coverage report`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-coverage-report "Link to this heading")

Generate code coverage report

**Usage:** `moon coverage report [args]... [COMMAND]`

**Arguments:**

* `<args>` — Arguments to pass to the coverage utility

**Options:**

* `-h`, `--help` — Show help for the coverage utility

## `moon coverage clean`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-coverage-clean "Link to this heading")

Clean up coverage artifacts

**Usage:** `moon coverage clean`

## `moon generate-build-matrix`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-generate-build-matrix "Link to this heading")

Generate build matrix for benchmarking (legacy feature)

**Usage:** `moon generate-build-matrix [OPTIONS] --output-dir <OUT_DIR>`

**Options:**

* `-n <NUMBER>` — Set all of `drow`, `dcol`, `mrow`, `mcol` to the same value
* `--drow <DIR_ROWS>` — Number of directory rows
* `--dcol <DIR_COLS>` — Number of directory columns
* `--mrow <MOD_ROWS>` — Number of module rows
* `--mcol <MOD_COLS>` — Number of module columns
* `-o`, `--output-dir <OUT_DIR>` — The output directory

## `moon upgrade`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-upgrade "Link to this heading")

Upgrade toolchains

**Usage:** `moon upgrade [OPTIONS]`

**Options:**

* `-f`, `--force` — Force upgrade
* `--dev` — Install the latest development version

## `moon shell-completion`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-shell-completion "Link to this heading")

Generate shell completion for bash/elvish/fish/pwsh/zsh to stdout

**Usage:** `moon shell-completion [OPTIONS]`

Discussion:
Enable tab completion for Bash, Elvish, Fish, Zsh, or PowerShell
The script is output on `stdout`, allowing one to re-direct the
output to the file of their choosing. Where you place the file
will depend on which shell, and which operating system you are
using. Your particular configuration may also determine where
these scripts need to be placed.

The completion scripts won't update itself, so you may need to
periodically run this command to get the latest completions.
Or you may put `eval "$(moon shell-completion --shell <SHELL>)"`
in your shell's rc file to always load newest completions on startup.
Although it's considered not as efficient as having the completions
script installed.

Here are some common set ups for the three supported shells under
Unix and similar operating systems (such as GNU/Linux).

Bash:

Completion files are commonly stored in `/etc/bash_completion.d/` for
system-wide commands, but can be stored in
`~/.local/share/bash-completion/completions` for user-specific commands.
Run the command:

```
$ mkdir -p ~/.local/share/bash-completion/completions
$ moon shell-completion --shell bash >> ~/.local/share/bash-completion/completions/moon
```

This installs the completion script. You may have to log out and
log back in to your shell session for the changes to take effect.

Bash (macOS/Homebrew):

Homebrew stores bash completion files within the Homebrew directory.
With the `bash-completion` brew formula installed, run the command:

```
$ mkdir -p $(brew --prefix)/etc/bash_completion.d
$ moon shell-completion --shell bash > $(brew --prefix)/etc/bash_completion.d/moon.bash-completion
```

Fish:

Fish completion files are commonly stored in
`$HOME/.config/fish/completions`. Run the command:

```
$ mkdir -p ~/.config/fish/completions
$ moon shell-completion --shell fish > ~/.config/fish/completions/moon.fish
```

This installs the completion script. You may have to log out and
log back in to your shell session for the changes to take effect.

Elvish:

Elvish completions are commonly stored in a single `completers` module.
A typical module search path is `~/.config/elvish/lib`, and
running the command:

```
$ moon shell-completion --shell elvish >> ~/.config/elvish/lib/completers.elv
```

will install the completions script. Note that use `>>` (append)
instead of `>` (overwrite) to prevent overwriting the existing completions
for other commands. Then prepend your rc.elv with:

```
`use completers`
```

to load the `completers` module and enable completions.

Zsh:

ZSH completions are commonly stored in any directory listed in
your `$fpath` variable. To use these completions, you must either
add the generated script to one of those directories, or add your
own to this list.

Adding a custom directory is often the safest bet if you are
unsure of which directory to use. First create the directory; for
this example we'll create a hidden directory inside our `$HOME`
directory:

```
$ mkdir ~/.zfunc
```

Then add the following lines to your `.zshrc` just before
`compinit`:

```
fpath+=~/.zfunc
```

Now you can install the completions script using the following
command:

```
$ moon shell-completion --shell zsh > ~/.zfunc/_moon
```

You must then open a new zsh session, or simply run

```
$ . ~/.zshrc
```

for the new completions to take effect.

Custom locations:

Alternatively, you could save these files to the place of your
choosing, such as a custom directory inside your $HOME. Doing so
will require you to add the proper directives, such as `source`ing
inside your login script. Consult your shells documentation for
how to add such directives.

PowerShell:

The powershell completion scripts require PowerShell v5.0+ (which
comes with Windows 10, but can be downloaded separately for windows 7
or 8.1).

First, check if a profile has already been set

```
PS C:\> Test-Path $profile
```

If the above command returns `False` run the following

```
PS C:\> New-Item -path $profile -type file -force
```

Now open the file provided by `$profile` (if you used the
`New-Item` command it will be
`${env:USERPROFILE}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

Next, we either save the completions file into our profile, or
into a separate file and source it inside our profile. To save the
completions into our profile simply use

```
PS C:\> moon shell-completion --shell powershell >>
${env:USERPROFILE}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

This discussion is taken from `rustup completions` command with some changes.

**Options:**

* `--shell <SHELL>` — The shell to generate completion for

  Default value: `<your shell>`

  Possible values: `bash`, `elvish`, `fish`, `powershell`, `zsh`

## `moon version`[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/commands.html#moon-version "Link to this heading")

Print version information and exit

**Usage:** `moon version [OPTIONS]`

**Options:**

* `--all` — Print all version information
* `--json` — Print version information in JSON format
* `--no-path` — Do not print the path

---

*This document was generated automatically by
[`clap-markdown`](https://crates.io/crates/clap-markdown).*

Contents
