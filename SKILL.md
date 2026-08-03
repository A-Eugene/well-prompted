---
name: well-prompted
description: >-
  Write, improve, review, or port a prompt or system prompt for a specific
  target LLM. Supplies what a model cannot know about its target: deprecated
  features and parameters that now error, guidance that reversed in the current
  model generation, and the cross-provider reflexes that are wrong for the
  target (Claude / OpenAI / Gemini). Use when the user says "write a prompt",
  "improve this system prompt", "make this prompt better for GPT/Claude/Gemini",
  "prompt engineering", or is drafting instructions for a model.
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
   source URLs before applying the file.** Skipping this on a hunch that
   nothing has changed defeats the file's purpose: you cannot suspect drift you
   have never heard of, and a stale file is worse than no file because it
   replaces your hedging with false confidence. No fetch capability available?
   Apply the snapshot and label it as of its fetch date.
3. **Apply the provider file.** It holds only what adds to or overrides the
   three principles below.
4. **Iterate against a check** — change one thing at a time, re-measure.

**Done when:** the target model is named (or its absence is stated); the
provider overlay was applied, or you state that none existed; and anything
unverified — an unfetched snapshot, an unknown model version — is stated in the
output rather than left implicit.

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

## Worked example

*Request:* "Write a system prompt for a Gemini 3 Flash summarizer."

**Reflex answer** — what a model produces without the overlay. Every line of it
is defensible generic advice, and three of them are wrong for this target:

```
<instructions>
  Summarize the input document in three sentences.
</instructions>
<input>{{DOCUMENT}}</input>

Set temperature to 0.9 for more natural, varied summaries.
Think step by step before writing the summary.
```

**With the procedure applied:**

1. Target = Gemini 3 Flash.
2. `models/gemini.md` is dated 2026-08-03; Gemini 3 predates it → snapshot is
   current, no fetch needed.
3. Overlay fires on four points — three corrections and one addition:
   - XML scaffolding is a Claude reflex. Gemini's idiom is labeled prefixes
     (`input:` / `output:`), with XML or Markdown reserved for the system
     instruction itself.
   - **Leave `temperature` at its default.** Gemini 3.x guidance explicitly
     advises against tuning sampling parameters — the reflex answer's "0.9 for
     variety" works against the model.
   - Gemini 2.5/3 generate internal reasoning automatically; "think step by
     step" is redundant at best.
   - And the overlay *adds* something absent from the reflex answer: Gemini's
     guidance is that prompts without few-shot examples "are likely to be less
     effective." Examples are not optional here.

```
You summarize documents. Respond with exactly three sentences, no preamble.

example:
input: <a short sample document>
output: <a three-sentence summary>

example:
input: <a sample with a different shape — a table, a transcript>
output: <a three-sentence summary>

input: {{DOCUMENT}}
output:
```

Note what carried the weight: not "be clear and specific" — the reflex answer
already was. The overlay changed the outcome by *overriding a default* and
supplying a fact about a specific model generation.

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
