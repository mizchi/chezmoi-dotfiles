---
title: "MoonBit's Package Manager Tutorial — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/toolchain/moon/package-manage-tour.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/toolchain/moon/package-manage-tour.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Ftoolchain/moon/package-manage-tour.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/toolchain/moon/package-manage-tour.md "Download source file")
* .pdf

# MoonBit's Package Manager Tutorial

## Contents

# MoonBit's Package Manager Tutorial[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#moonbit-s-package-manager-tutorial "Link to this heading")

## Overview[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#overview "Link to this heading")

MoonBit's build system seamlessly integrates package management and documentation generation tools, allowing users to easily fetch dependencies from mooncakes.io, access module documentation, and publish new modules.

[mooncakes.io](https://mooncakes.io/) is a centralized package management platform. Each module has a corresponding configuration file `moon.mod.json`, which is the smallest unit for publishing. Under the module's path, there can be multiple packages, each corresponding to a `moon.pkg.json` configuration file. The `.mbt` files at the same level as `moon.pkg.json` belong to this package.

Before getting started, make sure you have installed [moon](https://www.moonbitlang.com/download/).

## Setup mooncakes.io account[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#setup-mooncakes-io-account "Link to this heading")

Note

If you don't want to publish, you can skip this step.

If you don't have an account on mooncakes.io, run `moon register` and follow the guide. If you have previously registered an account, you can use `moon login` to log in.

When you see the following message, it means you have successfully logged in:

```
API token saved to ~/.moon/credentials.json
```

## Update index[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#update-index "Link to this heading")

Use `moon update` to update the mooncakes.io index.

![moon update cli](https://docs.moonbitlang.com/en/stable/_images/moon-update.png)

## Setup MoonBit project[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#setup-moonbit-project "Link to this heading")

Open an existing project or create a new project via `moon new`:

![moon new](https://docs.moonbitlang.com/en/stable/_images/moon-new.png)

## Add dependencies[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#add-dependencies "Link to this heading")

You can browse all available modules on mooncakes.io. Use `moon add` to add the dependencies you need, or manually edit the `deps` field in `moon.mod.json`.

For example, to add the latest version of the `Yoorkin/example/list` module:

![add deps](https://docs.moonbitlang.com/en/stable/_images/add-deps.png)

## Import packages from module[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#import-packages-from-module "Link to this heading")

Modify the configuration file `moon.pkg.json` and declare the packages that need to be imported in the `import` field.

For example, in the image below, the `hello/main/moon.pkg.json` file is modified to declare the import of `Yoorkin/example/list` in the `main` package. Now, you can call the functions of the third-party package in the `main` package using `@list`.

![import package](https://docs.moonbitlang.com/en/stable/_images/import.png)

You can also give an alias to the imported package:

```
{
    "is_main": true,
    "import": [
        { "path": "Yoorkin/example/list", "alias": "ls" }
    ]
}
```

Read the documentation of this module on mooncakes.io, we can use its `of_array` and `reverse` functions to implement a new function `reverse_array`.

![reverse array](https://docs.moonbitlang.com/en/stable/_images/reverse-array.png)

## Remove dependencies[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#remove-dependencies "Link to this heading")

You can remove dependencies via `moon remove <module name>`.

## Publish your module[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#publish-your-module "Link to this heading")

If you are ready to share your module, use `moon publish` to push a module to
mooncakes.io. There are some important considerations to keep in mind before publishing:

### Semantic versioning convention[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#semantic-versioning-convention "Link to this heading")

MoonBit's package management follows the convention of [Semantic Versioning](https://semver.org/). Each module must define a version number in the format `MAJOR.MINOR.PATCH`. With each push, the module must increment the:

* MAJOR version when you make incompatible API changes
* MINOR version when you add functionality in a backward compatible manner
* PATCH version when you make backward compatible bug fixes

Additional labels for pre-release and build metadata are available as extensions to the `MAJOR.MINOR.PATCH` format.

moon implements the [minimal version selection](https://research.swtch.com/vgo-mvs), which automatically handles and installs dependencies based on the module's semantic versioning information. Minimal version selection assumes that each module declares its own dependency requirements and follows semantic versioning convention, aiming to make the user's dependency graph as close as possible to the author's development-time dependencies.

### Readme & metadata[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#readme-metadata "Link to this heading")

Metadata in `moon.mod.json` and `README.md` will be shown in mooncakes.io.

Metadata consist of the following sections:

* `license`: license of this module, it following the [SPDX](https://spdx.dev/about/overview/) convention
* `keywords`: keywords of this module
* `repository`: URL of the package source repository
* `description`: short description to this module
* `homepage`: URL of the module homepage

### Moondoc[#](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html#moondoc "Link to this heading")

mooncakes.io will generate documentation for each module automatically.

The leading `///` comments of each toplevel will be recognized as documentation.
You can write markdown inside.

```
/// Get the largest element of a non-empty `Array`.
///
/// # Example
///
/// ```
/// maximum([1,2,3,4,5,6]) = 6
/// ```
///
/// # Panics
///
/// Panics if the `xs` is empty.
///
pub fn maximum[T : Compare](https://docs.moonbitlang.com/en/stable/toolchain/moon/xs : Array[T]) -> T {
  // TODO ...
}
```

You can also use `moon doc --serve` to generate and view documentation locally.

Contents
