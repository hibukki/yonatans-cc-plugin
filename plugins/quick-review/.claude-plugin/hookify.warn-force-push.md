---
name: warn-force-push
enabled: true
event: bash
pattern: "git push.*--force|git push.*-f"
action: warn
---

**Force push detected!**

Force pushing can overwrite remote history. Make sure you understand the implications before proceeding.
