---
name: global-memory-inject
description: "Fetch shared global memory on /new and inject into agent USER.md"
metadata:
  {
    "openclaw":
      {
        "emoji": "🧠",
        "events": ["command:new"],
        "requires": { "bins": ["mcporter"] },
      },
  }
---

# Global Memory Inject

Runs on `/new` — fetches all memories from OpenMemory (globalmemory skill) and writes
them to the agent's `USER.md` under a `## 🌐 Global Memory` section.

Memories are sorted by primary category and formatted as:
`- [category, ...] memory content`

The section is replaced on every `/new` so data stays fresh.
