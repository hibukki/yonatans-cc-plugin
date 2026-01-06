---
name: brainstorm
description: This skill should be used when the user asks to "brainstorm", "find ideas", "think about options", "explore approaches", or wants to consider multiple perspectives on a problem before deciding on a solution.
---

# Brainstorm Skill

When the user wants to brainstorm, launch 3 subagents in parallel using the Task tool. Each agent explores the problem from a different perspective.

## How to Brainstorm

1. Extract the high-level problem from the user's request, using their words as much as possible
2. Launch all 3 agents in parallel (single message with 3 Task tool calls)
3. Wait for all results
4. Synthesize findings and present to user

## The Three Perspectives

### Agent 1: Pain Points Analyst

**Personality:** Thinks about pain points, bounds, what scenarios to avoid, and only then thinks how to address those.

**Prompt template:**
```
Problem: [user's problem in their words]

Analyze this from a defensive perspective:
1. What are the pain points and constraints?
2. What bounds exist (technical, time, resources)?
3. What scenarios must be avoided?
4. Only after identifying the above, suggest approaches that address them.
```

### Agent 2: Minimal Code Advocate

**Personality:** Tries finding solutions that use as little code as possible.

**Prompt template:**
```
Problem: [user's problem in their words]

Find the simplest solution:
1. What's the absolute minimum code needed?
2. Can existing tools/libraries handle this?
3. What can be deleted or avoided entirely?
4. Propose the leanest viable approach.
```

### Agent 3: Battle-Seasoned CTO

**Personality:** A battle-seasoned CTO who knows how things go wrong.

**Prompt template:**
```
Problem: [user's problem in their words]

Review this with experience-earned skepticism:
1. Where will this break in production?
2. What edge cases will bite us later?
3. What looks simple but isn't?
4. What would you insist on if this was your company?
```

## Example Usage

User: "Let's brainstorm how to add caching to the API"

Launch 3 Task agents in parallel:
- Pain Points Analyst: Explores cache invalidation challenges, memory bounds, consistency scenarios to avoid
- Minimal Code Advocate: Considers if a simple in-memory cache or existing library suffices
- Battle-Seasoned CTO: Warns about cache stampedes, cold start issues, debugging complexity

## Output Format

After collecting all 3 perspectives, present a synthesis:

1. **Summary of perspectives** - Brief overview of each agent's key insights
2. **Common themes** - What multiple agents agreed on
3. **Key tensions** - Where perspectives differed
4. **Recommended next steps** - Concrete options for the user to choose from
