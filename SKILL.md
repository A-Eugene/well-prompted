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

Craft prompts in two layers: a **model-independent core** that holds for every
LLM, completed by a thin **model dispatch** that overlays the tactics specific
to the target model. Most of prompting generalizes (it is about removing
ambiguity and supplying context — intrinsic to how any model conditions on
input). A small, fast-drifting layer does not (delimiter syntax, role
mechanics, sampling knobs, reasoning-vs-standard instruction density). Keeping
them separate is what makes the advice both correct and maintainable.

## When to use

- Writing a new prompt or system prompt from scratch.
- Improving, debugging, or reviewing an existing prompt.
- Porting a prompt from one model to another.
- Any task whose output is "instructions for an LLM."

## How to apply (procedure)

1. **Identify the target model** — the model the prompt is *for* (from the
   user's request or the environment), not the model you happen to be running.
   If unknown, ask, or default to the most general branch and say so.
2. **Apply the invariant core** below. This is the bulk of the work.
3. **Overlay the model dispatch:** load `models/<provider>.md` for the target
   and apply its tactics *on top of* the core. Provider files hold only what
   adds to or overrides the core — never a re-statement of it.
4. **On high stakes or suspected drift, fetch the live source.** Each provider
   file lists its official URLs and a fetch date. Model-specific guidance
   changes often; when it matters, re-fetch and prefer the live doc over the
   snapshot.
5. **Iterate against a check.** Prompting is empirical — change one thing at a
   time and test against the success criterion.

---

## I. Invariant core (model-independent)

Nothing here references a specific model. Stated as intent, not rigid script —
apply what the task warrants.

1. **Start from success criteria and a way to test.** Know what "good" looks
   like and how you'll check it before tuning wording. Not every failure is a
   prompting problem (some are model, retrieval, or tooling).
2. **Be clear, specific, and unambiguous.** Say exactly what you want, the
   desired output format, and the constraints. When order or completeness
   matters, give sequential steps as a numbered list. Assume the model has no
   context you did not provide.
3. **Give context and the *why*.** Explaining the motivation behind an
   instruction ("this will be read aloud, so avoid ellipses") lets the model
   generalize to cases you didn't enumerate — more robust than a bare rule.
4. **Show, don't only tell.** Examples (few-shot / multishot) are among the
   most reliable ways to steer format, tone, and structure. Use 3–5 that are
   *relevant* (mirror the real task) and *diverse* (cover edge cases so the
   model doesn't overfit a spurious pattern).
5. **Delimit the parts.** Separate instructions, context, input, and examples
   with consistent, labeled boundaries so the model never confuses data for
   instructions. (Which delimiter — XML, markdown, prefixes — is model-specific;
   see dispatch.)
6. **Decompose complex work.** One prompt should do one coherent job. Split a
   large task into sub-steps or a chain of prompts; aggregate the pieces. This
   beats one overloaded prompt on both accuracy and debuggability.
7. **Put stable behavior in the system/developer message; per-request
   specifics in the user turn.** Persona, rules, and format live at the top of
   the authority stack; the specific ask lives with the request.
8. **Let the model reason before it answers on hard tasks** — but calibrate how
   hard you push this to the model class. Deliberate reasoning helps; *forcing*
   step-by-step on a model that already reasons internally can hurt (see
   dispatch).
9. **Constrain the output shape explicitly** when you need structure — a
   schema, a format, "no preamble." Prefer the model's native structured-output
   feature over brittle formatting hacks.
10. **Iterate empirically, one change at a time.** Rephrase, reorder, or add an
    example and re-measure. Prompting is search, not authorship.

---

## II. Model dispatch (model-specific overlay)

Identify the target model, then apply the matching file. Each file is a
snapshot of the provider's official guidance plus its source URLs.

| Target | File | Signature tactics (see file for detail) |
|---|---|---|
| **Anthropic / Claude** | `models/anthropic.md` | XML tags as the delimiter; role via system prompt; explain the *why*; prefill **deprecated** on 4.6+; calibrate thinking depth; literal instruction-following (state scope). |
| **OpenAI / GPT** | `models/openai.md` | Instruction hierarchy (`developer` > `user`); Identity/Instructions/Examples/Context sections; version prompts in code; **reasoning models want high-level guidance, GPT models want precise instructions**. |
| **Google / Gemini** | `models/gemini.md` | *Always* few-shot; prefixes to structure; specify constraints + format; tune sampling params (temperature, topK, topP) as a first-class lever. |

**Fallback:** unknown or unlisted target → apply the invariant core only, and
tell the user no model-specific overlay was available. Do not borrow one
provider's model-specific tactic (e.g. XML-everything, forced CoT) as if it were
universal — that is the exact failure this two-layer design prevents.

## Maintenance

- Provider files carry **source URLs + a fetch date**. Refresh by re-fetching
  those URLs and updating the file and date. The core rarely needs changes;
  the dispatch does.
- Adding a provider = adding one `models/<provider>.md` and a dispatch row.
  Nothing in the core changes.
- **Granularity rule — separate where advice diverges, no finer.** Provider-
  shared tactics (delimiters, roles, features, deprecations) live at the top of
  the provider file. Per-model differences (effort, prescription tolerance,
  reasoning-class) are **rows in a calibration table**, not separate files —
  a file per model name would duplicate the shared 80% and multiply drift.
  Promote a model to its own file only when its guidance both materially
  diverges from siblings *and* outgrows a table row.
- Keep the core model-free (null test: if a clause only applies to one model,
  it belongs in that model's file, not the core).
