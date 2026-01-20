---
title: "Conversations — MoonBit v0.6.27 documentation"
source_url: "https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/conversations"
fetched_at: "2025-12-19T08:15:11.537167+00:00"
---



* [Show source](https://github.com/moonbitlang/moonbit-docs/blob/main/next/pilot/moonbit-pilot/conversations.md?plain=1 "Show source")
* [Suggest edit](https://github.com/moonbitlang/moonbit-docs/edit/main/next/pilot/moonbit-pilot/conversations.md "Suggest edit")
* [Open issue](https://github.com/moonbitlang/moonbit-docs/issues/new?title=Issue%20on%20page%20%2Fpilot/moonbit-pilot/conversations.html&body=Your%20issue%20content%20here. "Open an issue")

* [.md](https://docs.moonbitlang.com/en/stable/_sources/pilot/moonbit-pilot/conversations.md "Download source file")
* .pdf

# Conversations

## Contents

# Conversations[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/conversations.html#conversations "Link to this heading")

## Background[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/conversations.html#background "Link to this heading")

If you encounter particularly good conversations (such as those that solved big problems for you, or when MoonBit Pilot performed exceptionally well and you want to share), or if they don't meet expectations and you want to analyze why they weren't good afterward, then conversation management and export become very useful. Let's see how to use them specifically.

## List All Conversations in Current Project[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/conversations.html#list-all-conversations-in-current-project "Link to this heading")

```
moon pilot conversations
```

```
1. 0ada20c9
   Name: Session 7/18/2025, 2:30:40 PM
   Description: Interactive conversation
   Messages: 0
   Created: 7/18/2025, 2:30:40 PM
   Updated: 7/18/2025, 2:30:40 PM

2. e1a5b071
   Name: Session 7/17/2025, 11:55:38 AM
   Description: Interactive conversation
   Messages: 18
   Created: 7/17/2025, 11:55:38 AM
   Updated: 7/17/2025, 11:56:32 AM
```

## View Conversation Details[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/conversations.html#view-conversation-details "Link to this heading")

```
moon pilot conversation 2b2fda32
```

## Export to Markdown Format[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/conversations.html#export-to-markdown-format "Link to this heading")

```
moon pilot conversation 2b2fda32 --output conversation.md
```

Opening the file shows the following result:

```
# Conversation: 2b2fda32-f045-43e9-a51f-37d3ec93c21c

**Name:** Session 7/8/2025, 2:47:46 PM
**Description:** Interactive conversation
**Created:** 7/8/2025, 2:47:46 PM
**Updated:** 7/8/2025, 2:48:25 PM
**Messages:** 6

## 👤 User

### Content

Run echo hello until all errors are fixed

**Timestamp:** 7/8/2025, 2:48:01 PM

---

## 🤖 Assistant

### Content

I will run the `echo hello` command for you. This is a simple command that should not produce any errors.

**🔧 Tool Call:** Execute command (execute_command)

**Parameters:**
- **command:** echo hello
- **timeout:** 5000

**Timestamp:** 7/8/2025, 2:48:06 PM

---

## 🔧 Tool

### Content

**🔧 Tool:** Execute command (execute_command)

**Result:**

Command executed successfully.
=== STDOUT ===
hello

=== STDERR ===

...
```

## Export to JSON Format[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/conversations.html#export-to-json-format "Link to this heading")

```
moon pilot conversation 2b2fda32 --output conversation.json
```

The output result is as follows:

```
{
  "created_at": 1751957266580,
  "description": "Interactive conversation",
  "id": "2b2fda32-f045-43e9-a51f-37d3ec93c21c",
  "messages": [
    {
      "content": "{\"content\":\"Run echo hello until all errors are fixed\",\"role\":\"user\"}",
      "id": "79a14c23-343e-457d-b0bb-5a069c36a7a0",
      "role": "user",
      "timestamp": 1751957281111
    },
    // ...
  ],
  "name": "Session 7/8/2025, 2:47:46 PM",
  "updated_at": 1751957305413
}
```

## Use Cases[#](https://docs.moonbitlang.com/en/stable/pilot/moonbit-pilot/conversations.html#use-cases "Link to this heading")

Conversation export is useful for:

* **Documentation**: Save successful problem-solving sessions for future reference
* **Sharing**: Share impressive MoonBit Pilot interactions with your team
* **Analysis**: Review conversations that didn't meet expectations to understand what went wrong
* **Training**: Use successful patterns to improve future interactions
* **Debugging**: Export detailed logs when reporting issues or seeking support

Contents
