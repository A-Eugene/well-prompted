# Model dispatch — Google / Gemini

> **Sources** (fetched 2026-08-03):
> - Prompt design strategies: https://ai.google.dev/gemini-api/docs/prompting-strategies
>
> Re-fetch if the target model is newer than the date above.
> Models named as current: **Gemini 3**, **Gemini 3 Flash**, Gemini 2.5.

## Errors your priors will cause

- **Do not tune sampling parameters on Gemini 3.x.** Google now *"strongly
  recommend[s] keeping them at their default values for Gemini 3.x models."*
  This **reverses** the long-standing Gemini guidance that `temperature` /
  `topK` / `topP` are a first-class lever — that advice still applies to older
  Gemini generations only. Raising temperature "for creativity" on a 3.x model
  is now working against the model.
- **Thinking is automatic on Gemini 2.5 and 3.** They generate internal
  reasoning text on their own — do not hand-write chain-of-thought scaffolding.
- **XML is fine here now.** System instructions are documented as *"structured
  XML tags or Markdown"* for role, constraints, and output format. The older
  prefixes-not-XML framing no longer holds for system instructions.

## The strongest few-shot stance of the three providers

- **Always include few-shot examples.** Google states plainly that prompts
  *without* few-shot examples "are likely to be less effective." Zero-shot is
  the exception, not the default — this is the first thing to add to a weak
  Gemini prompt.
- **Keep example formatting identical across examples.** Inconsistent structure
  in the examples produces inconsistent output format.

## Structure and content

- **Prefixes** (`input:`, `output:`, `example:`) remain the idiom for marking
  segments *within* a prompt; XML/Markdown for system instructions.
- **Specify constraints** — say what to do *and* what not to do (Gemini's guide
  is more comfortable with negative constraints than Anthropic's).
- **Define the response format** explicitly: table, bulleted list, keywords,
  sentence, paragraph, elevator pitch.
- Add the context the model needs rather than assuming it.
- **Fallback responses:** specify what the model should return when it cannot
  answer, rather than leaving it to improvise.

## Decomposition and iteration

- Break instructions down, chain sequential prompts, aggregate parallel
  responses.
- When results underperform: rephrase, switch to an analogous task framing, or
  **change the order of prompt content**.

## Also on the page

Grounding and code execution, and an agentic-workflows section — fetch these
when the task needs them rather than working from this summary.
