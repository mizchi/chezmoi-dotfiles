---
title: "Integrate skills into your agent - Agent Skills"
source_url: "https://agentskills.io/integrate-skills"
fetched_at: "2025-12-22T14:52:12.709Z"
---

This guide explains how to add skills support to an AI agent or development tool. ## [​](https://agentskills.io/integrate-skills.html#integration-approaches)

Integration approaches

The two main approaches to integrating skills are: **Filesystem-based agents** operate within a computer environment (bash/unix) and represent the most capable option. Skills are activated when models issue shell commands like `cat /path/to/my-skill/SKILL.md`. Bundled resources are accessed through shell commands. **Tool-based agents** function without a dedicated computer environment. Instead, they implement tools allowing models to trigger skills and access bundled assets. The specific tool implementation is up to the developer. ## [​](https://agentskills.io/integrate-skills.html#overview)

Overview

A skills-compatible agent needs to: 1. **Discover** skills in configured directories
1. **Load metadata** (name and description) at startup
1. **Match** user tasks to relevant skills
1. **Activate** skills by loading full instructions
1. **Execute** scripts and access resources as needed

## [​](https://agentskills.io/integrate-skills.html#skill-discovery)

Skill discovery

Skills are folders containing a `SKILL.md` file. Your agent should scan configured directories for valid skills. ## [​](https://agentskills.io/integrate-skills.html#loading-metadata)

Loading metadata

At startup, parse only the frontmatter of each `SKILL.md` file. This keeps initial context usage low. ### [​](https://agentskills.io/integrate-skills.html#parsing-frontmatter)

Parsing frontmatter

Report incorrect code

Copy

Ask AI

```
function parseMetadata(skillPath):
    content = readFile(skillPath + "/SKILL.md")
    frontmatter = extractYAMLFrontmatter(content)

    return {
        name: frontmatter.name,
        description: frontmatter.description,
        path: skillPath
    }
```

### [​](https://agentskills.io/integrate-skills.html#injecting-into-context)

Injecting into context

Include skill metadata in the system prompt so the model knows what skills are available. Follow your platform’s guidance for system prompt updates. For example, for Claude models, the recommended format uses XML: Report incorrect code

Copy

Ask AI

```
<available_skills>
  <skill>
    <name>pdf-processing</name>
    <description>Extracts text and tables from PDF files, fills forms, merges documents.</description>
    <location>/path/to/skills/pdf-processing/SKILL.md</location>
  </skill>
  <skill>
    <name>data-analysis</name>
    <description>Analyzes datasets, generates charts, and creates summary reports.</description>
    <location>/path/to/skills/data-analysis/SKILL.md</location>
  </skill>
</available_skills>
```

For filesystem-based agents, include the `location` field with the absolute path to the SKILL.md file. For tool-based agents, the location can be omitted. Keep metadata concise. Each skill should add roughly 50-100 tokens to the context. ## [​](https://agentskills.io/integrate-skills.html#security-considerations)

Security considerations

Script execution introduces security risks. Consider: - **Sandboxing**: Run scripts in isolated environments
- **Allowlisting**: Only execute scripts from trusted skills
- **Confirmation**: Ask users before running potentially dangerous operations
- **Logging**: Record all script executions for auditing

## [​](https://agentskills.io/integrate-skills.html#reference-implementation)

Reference implementation

The [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) library provides Python utilities and a CLI for working with skills. For example: **Validate a skill directory:** Report incorrect code

Copy

Ask AI

```
skills-ref validate <path>
```

**Generate `< available_skills >` XML for agent prompts:** Report incorrect code

Copy

Ask AI

```
skills-ref to-prompt <path>...
```

Use the library source code as a reference implementation.