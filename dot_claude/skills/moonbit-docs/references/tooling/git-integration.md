---
title: "Git Integration — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/pilot/moonbit-pilot/git-integration.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/pilot/moonbit-pilot/git-integration.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Fpilot/moonbit-pilot/git-integration.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/pilot/moonbit-pilot/git-integration.md "Download source file")
* .pdf

# Git Integration

## Contents

# Git Integration[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#git-integration "Link to this heading")

## Background[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#background "Link to this heading")

Currently, there are two approaches to managing AI modifications: git-based solutions and checkpoint-based solutions. We believe the git approach is superior, as it can effectively utilize existing IDE review tools, provides a clear timeline, and has good rollback characteristics. Therefore, we decided to have MoonBit Pilot use git to manage both manual user modifications and agent modifications.

You no longer need to fear AI making chaotic code changes!

## Setup[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#setup "Link to this heading")

We introduce a configuration file for the first time. Create a file `.moonagent/moonagent.yml` in your current project with the following content:

```
# MoonBit Pilot Project Configuration
# This configuration file controls moon pilot behavior for this project

# Enable automatic commits when files are modified
auto_commit: true
```

After this, restart and enter moon pilot for the changes to take effect.

## How It Works[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#how-it-works "Link to this heading")

MoonBit Pilot follows a structured git workflow to ensure clean separation between user and agent modifications:

### Detection Phase[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#detection-phase "Link to this heading")

When you submit a requirement, MoonBit Pilot first analyzes the current git state to detect any uncommitted changes. This includes:

* Modified files in the working directory
* Staged changes ready for commit
* New untracked files that may be relevant to your project

### User Work Preservation[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#user-work-preservation "Link to this heading")

If MoonBit Pilot detects that you have previously modified code, it will automatically create a commit for your work before making any modifications. This ensures your changes are safely preserved with a clear commit message like:

```
moonagent_pre_user work before implementing authentication
```

### Agent Modifications[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#agent-modifications "Link to this heading")

After preserving your work, MoonBit Pilot proceeds with its own modifications. It analyzes your requirements, implements the necessary changes, and creates a separate commit with a descriptive message:

```
moonagent_post_implemented JWT authentication with tests
```

### Workflow Benefits[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#workflow-benefits "Link to this heading")

This two-commit approach provides:

* **Clear Attribution**: Distinguishes between user and agent contributions
* **Safe Experimentation**: Your work is always preserved before agent modifications
* **Granular Control**: Each change set can be reviewed, modified, or reverted independently
* **Conflict Resolution**: Reduces merge conflicts by maintaining clean commit boundaries

## Managing Commit History[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#managing-commit-history "Link to this heading")

If you don't like these commit messages, you can:

1. **Rebase**: Merge multiple commits into one using interactive rebase
2. **Rewrite**: Add your preferred commit message
3. **Submit**: Create a proper PR for submission

This approach provides several benefits:

* **Clear history**: Each change is tracked with timestamps and attribution
* **Easy review**: Use familiar git tools to review changes
* **Safe rollback**: Easily revert specific changes if needed
* **Collaboration**: Share and discuss changes using standard git workflows

## Best Practices[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/git-integration.html#best-practices "Link to this heading")

* Review agent commits before merging to main branches
* Use meaningful branch names when working with MoonBit Pilot
* Combine related commits before creating pull requests
* Keep the git history clean for better collaboration

Contents
