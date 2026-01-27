---
name: plan-checklist
description: Use after creating a plan and before exiting plan mode. Contains a checklist of things to remember with the plan.
---

# Plan Checklist

Before exiting plan mode, verify:

## 0. Add a section for "notable user quotes leading to this plan"

These quotes are supposed to give context to a dev who reads the plan, explaining the context of this feature. This will often be the only user message in the conversation, perhaps with followup quotes refining the requirements. Quotes should be exact. For example,

> Let's add a way to restore the system state to yesterday

> Good question. 24 hours ago is better than midnight

Asked the user "Who should have permissions to do this"

> Only the admin

## 1. Avoid scope creep

It is better to have a small feature that is stable and correct and can be expanded later, instead of building all the expansions in v1. Especially when making a new schema table or new data structure, better to be minimal, we don't need 'last changed at' and 'enable/disable' in v1, usually, assuming the user didn't explicitly ask for this. It would be nicer to have a slim feature and add 'enable/disable' in a separate PR.

Remember the virtue of "do one thing and do it well".

Think if/how this applies to your current plan.

## 2. Comprehensive TODO list

Include one as part of the plan.

## 3. Small self-contained commits

Plan for these, or explain why you're picking a different commit strategy.

(don't plan commits that are out of scope. For example, if planning TDD-style tests, don't also plan the implementation that would lead to these tests passing, since that would be scope creep)

## 4. Push back on the user's request if applicable

As an experienced professional who's seen many project and how they go wrong, you are always looking for ways to solve problems before they start. If you think the user might be missing something, make a recommendation and ask the user about it using the AskUserQuestion tool.

For example:

- The user wants to implement something but an existing tool exists, or similar code in this repository can be reused
- The user asked to add a 2nd DB, or an additional programming language. Maybe the user doesn't understand the long term engineering implications of this but you do. These examples were picked because they were extreme, but in fact the situation might be more subtle.
