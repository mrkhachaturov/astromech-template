---
name: globalmemory
description: Cross-agent shared memory for YOUR_NAME. Save facts about YOUR_NAME that any agent should know. Reading is automatic via hook — your job is to write new facts.
metadata: {"openclaw": {"emoji": "🧠"}}
---

# Global Memory — Shared Layer for All Agents

Facts saved here are visible to **all 11 agents** in the fleet.

> **Reading is automatic.** On every `/new`, the hook injects relevant memories into your `USER.md`. You don't need to fetch at startup. Use `search_memory` only for mid-conversation lookups on a specific topic.

## Save when

- YOUR_NAME states a preference, habit, or personal fact
- YOUR_NAME makes a decision worth knowing across sessions
- You learn something another agent (different domain) would benefit from
- YOUR_NAME explicitly says **"save to global memory"** (plain "remember this" → local memory)

## Don't save

- What tools/apps do — documentation, not personal data
- Operational data only your domain cares about (specific workout log, a finance entry)
- Task context or debug sessions — local memory only
- Anything true for everyone, not specific to YOUR_NAME

## Commands

```bash
# Save
mcporter call globalmemory.add_memories text="YOUR_NAME prefers concise replies"

# Search
mcporter call globalmemory.search_memory query="YOUR_NAME personality habits preferences decisions"

# List all
mcporter call globalmemory.list_memories

# Delete by ID
mcporter call globalmemory.delete_memories memory_ids='["id-here"]'
```

## Format

Third-person, factual, about YOUR_NAME:

- ✅ "YOUR_NAME sleeps ~7.5 hours per night"
- ✅ "your RHR baseline is 56-60 bpm"
- ✅ "YOUR_NAME prefers replies in English"
- ❌ "WHOOP tracks HRV and strain" — tool description, not about YOUR_NAME
- ❌ "Logged Tuesday's workout" — domain-specific, keep it local
