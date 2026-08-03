# Model dispatch — OpenAI / GPT

> **Sources** (fetched 2026-08-03):
> - Prompt engineering guide: https://developers.openai.com/api/docs/guides/prompt-engineering
>
> Re-fetch if the target model is newer than the date above.
> Current default recommended by the guide: **gpt-5.6**.

## Counter-pull — what your Claude reflexes get wrong here

- **Roles are load-bearing, not decoration.** `developer` messages are
  application instructions and are **prioritized ahead of `user`**; user input
  cannot override them. Put authoritative rules, persona, and format in
  `developer`. The `instructions` parameter outranks a prompt passed in
  `input`.
- **Sectioned markdown, not XML-everything.** The canonical developer-message
  layout is **Identity → Instructions → Examples → Context**, with markdown
  headers. Use XML only to fence blocks that could be mistaken for data.
- **Order the prompt for the cache.** Put content you reuse across calls at the
  *beginning* — prompt caching keys on the stable prefix, so cache-friendly
  ordering is a cost and latency lever, not just style.

## Model class is the branch, not the model name

The advice-changing axis is **reasoning-class**. Add new models as rows under a
branch; do not make a file per model name.

| Branch | Members | How to prompt |
|---|---|---|
| **Reasoning-tuned** | o-series, reasoning/"thinking" variants, gpt-5.x with `reasoning` set | Like a **senior co-worker**: give the goal and constraints, let it work out the details. **Do not force explicit chain-of-thought** — over-instruction degrades it. |
| **Standard GPT** | GPT-4.1-class, gpt-5.x without reasoning | Like a **junior co-worker**: explicit, detailed, step-by-step. Little inference-in-the-gaps, so under-specification hurts. |

Reasoning models are slower and more expensive — the branch is a cost decision
as much as a prompting one. Control depth with `reasoning: {effort: ...}`.

## Agentic prompts

The guide names three practices; include them explicitly for agent workloads:

1. **Planning** — "resolve the full query before yielding control," decomposing
   into sub-tasks.
2. **Transparency** — "before you call a tool explain why you are calling it."
3. **Progress tracking** — a TODO-list tool or rubric to enforce structured
   planning.

For gpt-5.6 coding work the guide additionally emphasizes explicit role and
workflow guidance, testing/validation steps, tool-use examples, and markdown
standards for clean output.

## Examples, context, structure

- Few-shot with a **diverse range of inputs → desired outputs**.
- Supply proprietary context directly; for large or changing knowledge use
  **RAG** and constrain answers to it.
- Prefer **Structured Outputs** (JSON) over formatting instructions when you
  need a schema.
- Context windows range from ~100k to ~1M (GPT-4.1-class); check the model doc
  rather than assuming.

## Engineering discipline

**Version prompts in code**, not as opaque reusable blobs — enables typed
inputs, code review, tests, and normal deployment. Treat a production prompt
like source.
