---
title: "MoonBit VSCode Plugin — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/toolchain/vscode/index"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/toolchain/vscode/index.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/toolchain/vscode/index.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Ftoolchain/vscode/index.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/toolchain/vscode/index.md "Download source file")
* .pdf

# MoonBit VSCode Plugin

## Contents

# MoonBit VSCode Plugin[#](https://docs.moonbitlang.com/en/stable/toolchain/vscode/index.html#moonbit-vscode-plugin "Link to this heading")

MoonBit provides a plugin for Visual Studio Code, available in the
[Visual Studio MarketPlace](https://marketplace.visualstudio.com/items?itemName=moonbit.moonbit-lang)
and [Open VSX Registry](https://open-vsx.org/extension/moonbit/moonbit-lang).

## Commands[#](https://docs.moonbitlang.com/en/stable/toolchain/vscode/index.html#commands "Link to this heading")

The plugin provides several commands, available through
[command palettes](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette)

* Select backend: It allows you to switch between several backends
* Restart MoonBit language server: It allows you to restart the language server,
  in case it's unresponsive or has some stale state.
* Install MoonBit toolchain: Manually triggers the installation process. The
  extension will check if the installed MoonBit toolchain matches the
  extension's version.
* Get lsp's compiler version: It will display the MoonBit compiler version used
  by the extension.
* Toggle multiline string: It can help switching the chosen text between a plain
  text and the MoonBit's
  [multiline string syntax](https://docs.moonbitlang.com/en/stable/language/fundamentals.html#string)

## Actions[#](https://docs.moonbitlang.com/en/stable/toolchain/vscode/index.html#actions "Link to this heading")

The plugin also provides several actions, available through
[quick fix](https://code.visualstudio.com/docs/editing/refactoring#_code-actions-quick-fixes-and-refactorings)

* Add missing arms: It allows you to fill up the branches of a `match`
  expression when encountering [Error 0011](https://docs.moonbitlang.com/en/stable/language/error_codes/E0011.html)

## Code Lens[#](https://docs.moonbitlang.com/en/stable/toolchain/vscode/index.html#code-lens "Link to this heading")

The plugin provides code lens for each top-level code block, especially test
blocks.

The provided functionalities are:

* Format: format the code block
* Test / Bench: test or bench the test block
* Debug (JavaScript backend only): test the test block with debugger
* Update: update the [snapshot tests](https://docs.moonbitlang.com/en/stable/language/tests.html#snapshot-tests) in the
  code block
* Trace: turn on/off the tracing of the test block where each assignment will
  have the value rendered next to it

Contents
