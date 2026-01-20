---
name: agentskills
description: agentskills documentation assistant. Provides access to agentskills documentation and guides.
---

# agentskills Skill

This skill provides access to agentskills documentation.

## Usage

1. Search or read files in `references/` for relevant information
2. Each file has frontmatter with `source_url` and `fetched_at`
3. Always cite the source URL in responses

## Claude Skills Marketplace

Official skills repository: https://github.com/anthropics/skills

### Install from Marketplace

```bash
# Add marketplace
/plugin marketplace add anthropics/skills

# Install skills
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
```

### SKILL.md Structure

```markdown
---
name: my-skill-name
description: What this skill does and when to use it
---

# My Skill Name

[Instructions for Claude]

## Examples
## Guidelines
```

### Categories

- **Document Skills**: pdf, docx, pptx, xlsx
- **Creative & Design**
- **Development & Technical**
- **Enterprise & Communication**
