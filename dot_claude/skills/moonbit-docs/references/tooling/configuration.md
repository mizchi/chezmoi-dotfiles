---
title: "Configuration — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/configuration"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/pilot/moonbit-pilot/configuration.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/pilot/moonbit-pilot/configuration.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Fpilot/moonbit-pilot/configuration.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/pilot/moonbit-pilot/configuration.md "Download source file")
* .pdf

# Configuration

## Contents

# Configuration[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/configuration.html#configuration "Link to this heading")

## Ignoring Files and Directories[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/configuration.html#ignoring-files-and-directories "Link to this heading")

If you have directories or files that you want MoonBit Pilot to ignore, you can configure this by placing a `.moonagentignore` file in your project root directory. The format is identical to `.gitignore`.

If no `.moonagentignore` file is set, MoonBit Pilot will use the project's `.gitignore` as the default. Files excluded by either ignore file will not be monitored by MoonBit Pilot.

### .moonagentignore Format[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/configuration.html#moonagentignore-format "Link to this heading")

The `.moonagentignore` file follows the same syntax as `.gitignore`:

```
# Ignore specific files
secret.txt
config.local.json

# Ignore directories
node_modules/
.vscode/
dist/

# Ignore file patterns
*.log
*.tmp
temp_*

# Ignore nested patterns
docs/**/*.draft.md

# Use ! to negate (include) previously ignored patterns
!important.log
```

## Project Configuration[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/configuration.html#project-configuration "Link to this heading")

### moonagent.yml[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/configuration.html#moonagent-yml "Link to this heading")

Create a `.moonagent/moonagent.yml` file in your project root to configure MoonBit Pilot's behavior:

```
# MoonBit Pilot Project Configuration
# This configuration file controls moon pilot behavior for this project

# Enable automatic commits when files are modified
auto_commit: true

# Additional configuration options can be added here
```

### Available Configuration Options[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/configuration.html#available-configuration-options "Link to this heading")

* **auto\_commit**: When set to `true`, MoonBit Pilot will automatically create git commits before and after making changes to your code
* Additional configuration options may be added in future versions

Contents
