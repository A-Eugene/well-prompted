# Model dispatch — Google / Gemini

> Overlay on the invariant core. Only what is specific to Gemini appears here.
> **Sources** (fetched 2026-07-06):
> - Prompting strategies: https://ai.google.dev/gemini-api/docs/prompting-strategies

## Examples — the strongest stance of the three providers
- **Always include few-shot examples.** Google states plainly that prompts
  *without* few-shot examples "are likely to be less effective." Treat
  zero-shot as the exception, not the default. This is a stronger position than
  Anthropic's or OpenAI's, and the first thing to add to a weak Gemini prompt.

## Structure & delimiters
- Use **prefixes** to structure content and signal segments — e.g. `input:`,
  `output:`, `example:` — rather than XML tags. Prefixes also help specify the
  output format.

## Instructions, constraints, format
- Give **clear, specific instructions** (questions, tasks, entities).
- **Specify constraints** — say what to do *and what not to do* (e.g. "summarize
  in a single sentence").
- **Define the response format** explicitly (table, bulleted list, keywords,
  paragraph, elevator pitch, etc.).
- Add the **context** the model needs rather than assuming it.

## Decomposition & iteration
- **Break complex prompts down** — separate instructions, chain sequential
  prompts, or aggregate parallel task responses.
- **Iterate strategically:** rephrase, try analogous framings, or **reorder**
  prompt content when results underperform.

## Sampling parameters — a first-class lever (distinctive)
- Gemini's guide treats **parameter tuning as best practice**, unlike the other
  two: `temperature`, `topK`, `topP`, `max output tokens`, `stop sequences`.
- Practical: **raise temperature for creative/varied output** (e.g. style or
  fiction, where low temperature flattens natural variance); lower it for
  deterministic/extraction tasks. Don't leave these at default when output
  character matters.
