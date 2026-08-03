# Model dispatch — Anthropic / Claude

> **Sources** (fetched 2026-08-03):
> - Prompting best practices: https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/claude-prompting-best-practices
> - Per-model pages, same path: `prompting-claude-opus-5`, `prompting-claude-opus-4-8`,
>   `prompting-claude-sonnet-5`, `prompting-claude-fable-5` (Fable page also covers Mythos 5)
>
> Re-fetch if the target model is newer than the date above.

## Errors your priors will cause

These were correct practice for years and are now wrong. This section is the
main reason the file exists.

- **Prefilling the assistant turn returns a 400** on Claude 4.6+ and Mythos.
  Migrate: formatting/JSON/classification → Structured Outputs or a tool with
  an enum field; skipping preamble → instruct directly ("Respond directly
  without preamble; do not start with 'Here is…'"); continuations → move the
  partial text into the `user` turn.
- **`budget_tokens` returns a 400** on Claude 4.7+. Use
  `thinking: {type: "adaptive"}` and control depth with
  `output_config: {effort: ...}`; `max_tokens` is the hard ceiling.
- **Anti-laziness prompting now overtriggers.** Guidance written for older
  models ("CRITICAL: You MUST use this tool when…", "if in doubt, use [tool]")
  makes current models over-eager. Dial down to plain "Use this tool when…".
- **Do not force step-by-step CoT.** Current models reason natively; "think
  thoroughly" beats a hand-written plan. Manual `<thinking>`/`<answer>`
  scaffolding is a fallback for when thinking is *off*, not a default.
- **On Opus 5 specifically, delete your verification instructions.** See the
  calibration table.

## Thinking and effort

- Config: `thinking: {type: "adaptive"}` + `output_config: {effort: ...}`.
  Adaptive thinking outperforms manual extended thinking in Anthropic's evals.
- Defaults differ by model — check before assuming:
  - **Off when `thinking` is omitted:** Opus 4.6–4.8, Sonnet 4.6
  - **On by default:** Opus 5, Sonnet 5 (Opus 5 can disable only at effort ≤ `high`)
  - **Always on:** Fable 5, Mythos 5
- Triggering is promptable. Thinking too often (common with large system
  prompts): *"Thinking adds latency and should only be used when it will
  meaningfully improve answer quality."*

## Long context (20k+ tokens)

Distinctive to Anthropic and easy to get backwards:

- **Longform data at the top, query at the bottom.** Documents above your
  instructions and examples. Queries at the end improve response quality by up
  to ~30% on complex multi-document inputs.
- Wrap each document: `<documents>` → `<document index="n">` → `<source>` +
  `<document_content>`.
- **Ground in quotes first.** "Extract the relevant quotes into `<quotes>` tags,
  then answer from them" keeps the model on the relevant span.

## Structure and output control

- **XML tags are the delimiter**: `<instructions>`, `<context>`, `<input>`,
  `<example>` / `<examples>`. Consistent, descriptive names; nest for hierarchy.
- **Role in the `system` prompt** — one sentence measurably focuses behavior.
- **Explain the *why*** behind a rule; Claude generalizes from the rationale to
  cases you didn't enumerate.
- **Say what to do, not what not to do.** "Compose your response in flowing
  prose paragraphs" beats "do not use markdown."
- **Match your prompt's style to the desired output style.** Removing markdown
  from the prompt reduces markdown in the response. Non-obvious, cheap, works.
- **Claude defaults to LaTeX for math.** Plain text requires an explicit
  instruction naming the substitutes (`/`, `*`, `^`).
- Examples: 3–5, wrapped in `<example>` tags, relevant and diverse.

## Tool triggering

Phrasing decides whether the model acts or advises. *"Can you suggest some
changes"* → it suggests. *"Change this function"* → it does it. Set the default
posture explicitly with `<default_to_action>` or
`<do_not_act_before_instructions>` (sample blocks in the source doc).

## Per-model calibration

Effort/thinking depth is set at the API level, not prompted around.

| Model | Effort | Verbosity | Subagents | Watch for |
|---|---|---|---|---|
| **Opus 5** | Default `high`; use `low`/`medium` liberally, `xhigh` for demanding agentic work | Runs long by default, and **effort does not shorten it** — prompt for brevity explicitly (also for files it writes) | **Over-delegates** — cap it | **Remove verification and "double-check" instructions** — it self-verifies, and they cause over-verification. Also expands task scope; narrates corrections. Review prompts: "only report high-severity" is followed literally and suppresses findings — ask for everything, filter separately. |
| **Opus 4.8** | High-to-max for coding/agentic | Concise by default | **Under-spawns** — must be told | Follows instructions literally: state scope ("every section, not just the first"). |
| **Sonnet 5** | `high` baseline | Calibrate explicitly | Spawns readily; cheap tokens favor more verification | Tool-use triggering; literal instruction following; context awareness (tracks its own token budget). |
| **Fable 5 / Mythos 5** | Metered — `low` here exceeds prior models' `xhigh`; reserve high effort for the hard tail | — | — | **Degrades most under over-prescription** — keep instructions high-level. Thinking always on; never prompt for step-by-step. |

## Agentic system prompts

The source doc carries ready-made blocks for these; fetch rather than
paraphrase. Named here so you know to look:

- Long-horizon state tracking (git as state store, `tests.json`, `progress.txt`)
- Context awareness and multi-window workflows / compaction
- Balancing autonomy and safety (confirm before irreversible actions)
- Parallel tool calling (`<use_parallel_tool_calls>`)
- Over-engineering damping; avoid hardcoding to tests; temp-file cleanup
- `<investigate_before_answering>` to minimize hallucination in agentic coding
- Frontend aesthetics ("AI slop" damping)
