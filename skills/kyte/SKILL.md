---
name: kyte
description: Work with the company's kyte workspace — customers, contacts, deals, products, projects, time entries and hours, invoices, processes, goals and key results, people, teams, absences and the company's documents. Use when the person asks about any of these, wants something looked up, logged, booked, created, changed or removed in kyte, or asks a question their company data can answer.
version: 0.1.0
author: Pirol Labs
metadata:
  hermes:
    tags: [kyte, company-os, crm, projects, time-tracking]
    category: productivity
    requires_toolsets: [mcp]
---

# Working in kyte

kyte is the person's company workspace — the company OS by Pirol Labs. The `kyte` program on their
own computer serves that workspace to Hermes as tools, named `kyte_*`. You work **as that person**,
under their permissions: what they may not see does not exist for you, and what they may not change
you cannot change.

## When to use this

Whenever the question or the task touches the company: a customer, a contact, a deal, a product, a
project, hours, an invoice, a process, a goal, a person, a team, an absence, a document. Reach for
the kyte tools before you reason from memory — the workspace is the record, you are not.

## Look things up before you answer

- Prefer the kyte tools over guessing, and over asking the person for data the workspace already
  holds.
- The `*_list` tools page their results. Narrow with `search` first; read on with `offset` when the
  answer needs more rows. A list says how many rows there are in total — say so when you show only
  some.
- Use the ids the tools return. Never invent an id, and never reuse one from a different kind of
  record.

## Before you change anything

- Change only what the person asked for. When the request is ambiguous — which customer, which
  project, which week — ask, or show what you found and ask which one.
- A `*_delete` cannot be undone from here. Name the record you are about to delete and get a clear
  yes first.
- A tool that answers `ok: false` changed nothing. Say so, with its reason — never report a change
  that did not happen.

## After you changed something

Say in one or two sentences what you changed: which record, which fields, the values before and
after where you know them. Every change is recorded in kyte as made by an agent on the person's
behalf.

## What does not happen here

Apps, extensions and new data structures are built in kyte itself, in its Extend mode, not through
these tools. When the person wants a new field, table or app, tell them to build it there.

## When the workspace itself cannot answer

Sometimes the program runs but the workspace is not available — nobody has signed in for that
folder, or the company's team server cannot be reached. kyte then serves a single tool that
explains the situation instead of the usual ones. Call it, pass on what it says, and treat the
workspace as unreadable until it is fixed.

## When there are no kyte tools at all

The skill is installed but the connection is not: either the MCP server is not configured in
Hermes, or the `kyte` program is missing from this machine, or no workspace has been opened for it.
Say so plainly, and until it is fixed do not answer questions about the company — anything you say
about their customers, projects or hours without those tools is invention.

The person sets this up themselves; these are the steps, and `hermes mcp list` shows how far they
have come:

1. Add the server, once per machine:

   ```
   hermes mcp add kyte --command kyte --args mcp --db ~/.kyte/hermes
   ```

   Once the entry is in the Hermes MCP catalog, `hermes mcp install kyte` does the same thing and
   carries these instructions with it.

2. Install the kyte command line if `kyte --version` answers nothing. The installer and what it
   does are described at <https://kyte.pirol.ai/docs/en/mcp/> and in the README of
   <https://github.com/Pirol-ai/kyte-hermes>. It writes one program, usually to `~/.local/bin/kyte`
   — a folder that is not always on the `PATH` yet, which is why a bare `kyte` can still answer
   "command not found" to someone who did everything right.

3. Sign in once, for this connection's own folder:

   ```
   kyte login --db ~/.kyte/hermes
   ```

   That folder is Hermes's own copy of the workspace. kyte keeps an encrypted local copy and one
   folder serves one process, so a Hermes session and a kyte session in a terminal pointed at the
   same folder would be two writers on one database.

Then start a new Hermes session: the server is connected at session start, so a running session
does not pick it up.
