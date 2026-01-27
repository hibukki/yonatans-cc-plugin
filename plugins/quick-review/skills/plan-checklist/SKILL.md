---
name: plan-checklist
description: Use after creating a plan and before exiting plan mode. Contains a checklist of things to remember with the plan.
---

# Plan Checklist

Before exiting plan mode, verify:

## 1. Avoid scope creep

It is better to have a small feature that is stable and correct and can be expanded later, instead of building all the expansions in v1. Especially when making a new schema table or new data structure, better to be minimal, we don't need 'last changed at' and 'enable/disable' in v1, usually, assuming the user didn't explicitly ask for this. It would be nicer to have a slim feature and add 'enable/disable' in a separate PR.

Remember the virtue of "do one thing and do it well".

Think if/how this applies to your current plan.

## 2. Comprehensive TODO list

Include one as part of the plan.

## 3. Small self-contained commits

Plan for these, or explain why you're picking a different commit strategy.
