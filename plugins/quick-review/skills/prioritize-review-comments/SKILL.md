---
name: prioritize-review-comments
description: This skill should be used after receiving an automated code review, whether from a hook, Claude on GitHub, a review agent, or similar automated reviewer. Use when processing review comments to decide which to fix.
---

# Prioritize Review Comments

After receiving automated review feedback, apply this framework to decide what to fix.

## Core Principle

Make the current feature/PR as clean as possible. Don't let "minor" or "deferrable" labels excuse real issues within scope.

## What to Fix

**Fix these regardless of severity labels:**
- Issues directly related to the code you changed
- Problems in the feature you're implementing
- Anything that makes the current PR less clean
- "Minor" issues that take seconds to fix
- "Deferrable" issues that are actually in-scope

**The label doesn't matter.** If it's in the scope of your change and it's a valid point, fix it.

## What NOT to Fix

**Don't scope-creep:**
- Unrelated code that happens to be nearby
- Pre-existing issues in files you touched
- Suggestions that turn a small PR into a large refactor
- "While you're here..." improvements to other features

**Don't fix incorrect feedback:**
- Comments where the reviewer misunderstood the change
- Suggestions based on wrong assumptions
- "Improvements" that would break intended behavior

## Decision Framework

For each review comment, ask:

1. **Is it correct?** If the reviewer misunderstood, skip it.
2. **Is it in scope?** If it's about the feature/change you're making, fix it.
3. **Does the severity label matter?** No. "Minor" in-scope issues should still be fixed.

## Example Responses

**Fix:** "Minor: variable name could be clearer" → If it's in your changed code, rename it.

**Fix:** "Tiny nit: missing newline at end of file" → Takes 2 seconds, do it.

**Skip:** "While you're here, the function above could use better error handling" → Out of scope, different change.

**Skip:** "This should use the new API pattern" → If reviewer didn't realize you're intentionally matching existing code, explain and skip.
