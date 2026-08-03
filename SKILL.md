---
name: well-prompted
description: >-
  Write, improve, or review a prompt or system prompt for any LLM. Applies a
  model-independent core of prompting best practices, then overlays
  target-model-specific tactics (Claude / OpenAI / Gemini). Use when the user
  says "write a prompt", "improve this system prompt", "make this prompt better
  for GPT/Claude/Gemini", "prompt engineering", or is drafting instructions for
  a model.
---

# well-prompted

Most of prompting is already trained into any frontier model — "be specific,"
"give examples," "supply context" are dispositions, not discoveries. Restating
them changes nothing.

What a model *cannot* supply for itself is the fast-drifting layer: which
feature was deprecated last month, which parameter now returns a 400, which
behavior reversed in the current model generation, and which of its own reflexes
are wrong for a different provider. **That is what this skill is for.** The
files below are a gotcha sheet plus a fetch trigger, not a tutorial.

## When to use

- Writing a new prompt or system prompt from scratch.
- Improving, debugging, or reviewing an existing prompt.
- Porting a prompt from one model to another.
- Any task whose output is "instructions for an LLM."

## Procedure

1. **Identify the target model** — the model the prompt is *for*, not the model
   you are running on. If unknown, ask.
2. **Check the fetch date at the top of `models/<provider>.md`. If the target
   model is newer than that date, or the stakes are high, fetch the listed
   source URLs before applying the file.** Do not skip this on a hunch that
   nothing has changed — you cannot suspect drift you have never heard of, and
   a stale file is worse than no file because it replaces your hedging with
   false confidence.
3. **Apply the provider file.** It holds only what adds to or overrides the
   three principles below.
4. **Say what you did not verify.** If you applied the snapshot without
   fetching, say so.
5. **Iterate against a check** — change one thing at a time, re-measure.

---

## The three that bind

Everything else in the generic prompting canon is already the model's default
behavior. These three are not, because they are behavioral rather than
informational — they change what gets *done*, not what is known.

1. **Start from success criteria and a way to test.** Know what "good" looks
   like and how you'll check it before tuning wording. Not every failure is a
   prompting problem — some are model, retrieval, or tooling.
2. **Iterate one change at a time.** The default is to rewrite five things at
   once and declare victory. Prompting is search, not authorship.
3. **Never borrow one provider's tactic as universal.** Your structuring
   reflexes come from the model you are running on. Applying XML-everything to
   a model whose docs ask for labeled prefixes — or forcing chain-of-thought on
   a model that reasons internally — is the exact failure this two-layer design
   exists to prevent.

---

## Model dispatch

| Target | File | What the file is for |
|---|---|---|
| **Anthropic / Claude** | `models/anthropic.md` | Prefill and `budget_tokens` now 400; Opus 5 reverses verification and subagent advice; long-context ordering; effort/thinking API. |
| **OpenAI / GPT** | `models/openai.md` | `developer` > `user` hierarchy; reasoning-class is the branch, not model name; `reasoning.effort`; cache-friendly prompt ordering. |
| **Google / Gemini** | `models/gemini.md` | Always few-shot; **sampling-parameter advice reversed on Gemini 3.x**; thinking is automatic on 2.5/3. |

**Unknown or unlisted target:** apply the three principles, fetch that
provider's official prompting guide, and say no overlay was available.

## Maintenance

- Provider files carry **source URLs + a fetch date**. Refresh by re-fetching
  and updating both the content and the date.
- **Keep the files short.** Long files rot because nobody refreshes them; the
  fetch-first rule in step 2 retrieves detail on demand. Prefer naming a
  technique with its doc anchor over transcribing it.
- **Null test, applied ruthlessly.** If a clause states something a frontier
  model would already do unprompted, delete it. The file earns its place only
  where it corrects an error, supplies a post-cutoff fact, or counters a
  cross-provider reflex.
- **Granularity — separate where advice diverges, no finer.** Provider-shared
  tactics live at the top of the provider file. Per-model differences are
  **rows in a calibration table**, not separate files. Promote a model to its
  own file only when its guidance both materially diverges from siblings *and*
  outgrows a row.
