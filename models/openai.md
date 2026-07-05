# Model dispatch — OpenAI / GPT

> Overlay on the invariant core. Only what is specific to OpenAI models appears here.
> **Sources** (fetched 2026-07-06):
> - Prompt engineering guide: https://developers.openai.com/api/docs/guides/prompt-engineering
> - (redirected from the legacy `platform.openai.com/docs/guides/prompt-engineering`)

## Roles & instruction hierarchy
- **Use message roles deliberately.** `developer` messages are application
  instructions and are **prioritized ahead of `user` messages**. Put
  authoritative rules, persona, and format in the `developer` message; put the
  specific request in `user`.
- Design for this hierarchy: user input cannot override developer rules, which
  is what you want for guardrails and stable behavior.

## Structure
- Organize the prompt into labeled sections: **Identity / Instructions /
  Examples / Context.** Use markdown headers, and XML to mark logical
  boundaries where blocks could be confused with data.

## Examples & context
- Few-shot with a **diverse range of inputs → desired outputs**.
- Supply proprietary/task context directly; for large or changing knowledge use
  **retrieval-augmented generation (RAG)** and constrain answers to it.
- Plan for the context window (recent GPT-4.1-class models support very large —
  up to ~1M-token — windows, but relevant-context-first still wins).

## Model class is the primary branch (not model name)

Within OpenAI, the advice-changing axis is **reasoning-class**, not the specific
model. Group the target model into one of two branches and prompt accordingly;
this decides how to apply core rule #8 (let-the-model-reason). Add new models as
rows under whichever branch they belong to — do not make a file per model name.

| Branch | Members (examples) | How to prompt |
|---|---|---|
| **Reasoning-tuned** | o-series, reasoning/"thinking" variants | **High-level guidance**: state goal + constraints, let it plan. **Do NOT force explicit chain-of-thought** — it reasons internally and over-instruction degrades it. |
| **Standard GPT** | GPT-4.1 / GPT-5 non-reasoning | **Precise, explicit, detailed**: spell out steps and format. Little inference-in-the-gaps, so under-specification hurts. |

When unsure which branch a model is in, check the model card; default to
standard-GPT prompting only if it is clearly not a reasoning model.

## Engineering discipline
- **Version prompts in code**, not as opaque reusable blobs — enables typed
  inputs, code review, tests, and normal deployment. Treat a production prompt
  like source.
