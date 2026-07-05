# Model dispatch — Anthropic / Claude

> Overlay on the invariant core. Only what is specific to Claude appears here.
> **Sources** (fetched 2026-07-06):
> - Prompting best practices: https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/claude-prompting-best-practices
> - Overview: https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/overview
> - Per-model pages: `prompting-claude-opus-4-8`, `prompting-claude-sonnet-5`, `prompting-claude-fable-5` (under the same path)

## Structure & delimiters
- **XML tags are the preferred delimiter.** Wrap each content type in its own
  tag: `<instructions>`, `<context>`, `<input>`, and examples in
  `<example>` / `<examples>`. Nest when hierarchical (`<documents>` →
  `<document index="n">`). This is Claude's strongest structuring lever.
- **Give Claude a role via the `system` prompt.** Even one sentence ("You are a
  senior Python reviewer") measurably focuses tone and behavior.
- **Explain the *why* behind rules** — Claude generalizes from the rationale to
  cases you didn't list. Prefer "avoid ellipses because a TTS engine reads this
  aloud" over a bare "never use ellipses."

## Examples
- 3–5 examples, wrapped in `<example>` tags, relevant and diverse. You can ask
  Claude to critique your examples for coverage or generate more.

## Output control — prefill is deprecated
- **Prefilling the assistant turn is NO LONGER SUPPORTED on Claude 4.6+ and
  Mythos** (returns a 400). Migrate:
  - Formatting/JSON/classification → use **Structured Outputs** (schema) or a
    tool with an enum field.
  - Skipping preamble → instruct directly: "Respond directly without preamble;
    do not start with 'Here is…' / 'Based on…'." Or emit inside XML tags.
  - Continuations → move the partial text into the `user` turn and ask it to
    continue.
- Control verbosity explicitly; newer models are concise by default but honor
  "be thorough" / "be terse."

## Thinking & reasoning
- Claude's latest models reason natively. **Do not hand-force rigid
  step-by-step CoT** as a reflex — instead enable/allow extended and
  interleaved thinking for genuinely hard, multi-step work.
- Watch for **overthinking / excessive thoroughness** on simple tasks; tell it
  to stop early when the task is routine.

## Instruction following
- **Instructions are followed literally.** State scope explicitly ("revise
  *every* section, not just the first"; "return only the JSON") rather than
  expecting the model to infer the intended breadth.

## Per-model calibration

Everything above is provider-shared (holds across Claude models). Per-model
differences are a small set of dials, captured as rows below — not separate
files. Effort/thinking-depth is set at the harness/API level, not prompted
around. Add a model as a new row; promote it to its own file only if its
guidance both materially diverges *and* outgrows a row.

| Model | Effort / thinking default | Prescription tolerance | Notable defaults |
|---|---|---|---|
| **Opus 4.8** | High-to-max for coding/agentic; thinking on demand | **Literal** — state scope explicitly ("every section") | Under-spawns subagents unless told; strong agentic |
| **Sonnet 5** | High baseline; thinking-depth calibrated | Follows literally | Calibrate response length + tool-use triggering; cheaper tokens favor more verification |
| **Fable 5** | Metered — `low` here exceeds prior `xhigh`; reserve high effort for the hard tail | **Low — degrades most under over-prescription;** keep instructions high-level | Thinking **always on** — do not prompt for step-by-step |

Per-model pages (re-fetch when load-bearing): `prompting-claude-opus-4-8`,
`prompting-claude-sonnet-5`, `prompting-claude-fable-5`.

## Agentic
- Encourage **parallel tool calls** when operations are independent; manage
  **overeagerness**; use subagent orchestration and prompt chaining for
  long-horizon tasks.
