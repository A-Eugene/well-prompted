# well-prompted

An [agent skill](https://vercel.com/docs/agent-resources/skills) that helps an
LLM write, improve, review, or port **prompts** — using prompting best
practices that are correct *across* models without pretending the models are
identical.

It is built on one idea: **stratify the advice.** A large **model-independent
core** holds for every LLM; a thin **model dispatch** overlays the tactics that
are specific to the target model. The core is the bulk of the value and rarely
changes; the dispatch is small and updated as providers revise their guidance.

---

## The problem this solves

Prompting guides from Anthropic, OpenAI, and Google agree on ~80% — be clear
and specific, give examples, provide context, decompose the task, separate the
sections, iterate against a test. That agreement is not a coincidence: those
principles follow from how *any* autoregressive model conditions on its input,
not from a particular architecture.

The other ~20% genuinely differs, and getting it wrong is actively harmful:

- Claude leans on **XML tags**; OpenAI on a **`developer` > `user` role
  hierarchy**; Gemini on **prefixes + mandatory few-shot + sampling knobs**.
- **Reasoning models want high-level guidance and no forced chain-of-thought**;
  standard models want precise, explicit steps. Forcing CoT on a reasoning
  model *degrades* it.
- Provider-specific affordances change: **prefill is now deprecated on Claude
  4.6+** (returns a 400), so old "prefill the assistant turn" advice is wrong.

A single flattened "generic best practices" prompt would silently promote these
model-specific tactics into universal rules and be wrong on the wrong model
about a fifth of the time — with no signal about which fifth. So the naive
generalization is a bad idea. Abandoning generalization is also wrong, because
the shared 80% is real and valuable. The resolution is to **separate the two
layers** so each is applied only where it's true.

## The design

```
well-prompted/
├── SKILL.md            # the skill: invariant core + dispatch procedure + table
├── README.md           # this file
└── models/
    ├── anthropic.md    # Claude-specific tactics  (+ source URLs, fetch date)
    ├── openai.md       # OpenAI/GPT-specific tactics
    └── gemini.md       # Gemini-specific tactics
```

- **`SKILL.md` → Section I, Invariant core.** Ten model-free principles, stated
  as *intent* rather than rigid script. This is what applies to every prompt.
- **`SKILL.md` → Section II, Model dispatch.** A procedure + table: identify the
  target model, then load the matching `models/<provider>.md` and overlay its
  tactics on the core. Unknown target → core only, stated explicitly.
- **`models/*.md`.** Each file contains *only* what adds to or overrides the
  core for that provider — never a re-statement of the core — plus the official
  **source URLs** and the **date they were fetched**.

### Why this shape (not a single doc)

The split isn't tidiness — it's maintenance. Model-specific tactics drift fast
(the reasoning-model guidance recently *inverted* prior advice; prefill was
removed). The generalizable core does not. By isolating the volatile 20% into
three small files with dated sources, updating the skill means re-fetching one
file, while the stable core is never touched. This is the same
"invariant-core + model-dispatch" stratification used by well-built agent
kernels for exactly this drift problem.

## How the skill behaves when activated

1. **Identify the target model** — the model the prompt is *for*, taken from the
   request or environment (not the model currently running). If unknown, it asks
   or defaults to core-only and says so.
2. **Apply the invariant core** — the ten principles.
3. **Overlay the dispatch** — load `models/<provider>.md`, apply its tactics on
   top of the core.
4. **On high stakes or suspected drift** — re-fetch the provider's live docs
   (URLs are in each file) and prefer them over the snapshot.
5. **Iterate against a check** — one change at a time; prompting is empirical.

The dispatch table at a glance:

| Target | Signature tactics |
|---|---|
| **Anthropic / Claude** | XML delimiters, role via system prompt, explain the *why*, prefill deprecated (use Structured Outputs), calibrate thinking depth, literal instruction-following |
| **OpenAI / GPT** | `developer` > `user` hierarchy; Identity/Instructions/Examples/Context; version prompts in code; reasoning-vs-GPT instruction density |
| **Google / Gemini** | always few-shot; prefixes; explicit constraints + format; tune temperature/topK/topP |

## Provenance

The model-specific files are snapshots of each provider's **official**
documentation, fetched **2026-07-06**:

- Anthropic — `platform.claude.com/docs/.../claude-prompting-best-practices`
- OpenAI — `developers.openai.com/api/docs/guides/prompt-engineering`
- Google — `ai.google.dev/gemini-api/docs/prompting-strategies`

Each `models/*.md` restates its exact source URLs and fetch date. Because this
guidance drifts, treat the snapshots as a fast default and re-fetch when the
answer is load-bearing.

## Installation & use

This skill follows the [vercel-labs/skills](https://github.com/vercel-labs/skills)
convention (a directory with a `SKILL.md`). It was scaffolded with
`npx skills init well-prompted`.

Install it into a project or globally with the CLI:

```bash
# from a published git repo
npx skills add <owner>/<repo>

# or point at this directory / a hosted SKILL.md
npx skills add ./well-prompted
```

Once installed, it activates when you ask an agent to write, improve, review, or
port a prompt for a specific model.

### On Codex

The skill format is cross-agent: Codex reads skills from the same `SKILL.md`
convention (a directory with a `SKILL.md` carrying `name` + `description`), so
`well-prompted` is **Codex-compatible as-is** — its content is already
model-agnostic and ships the OpenAI/GPT overlay in `models/openai.md`. Install
it into Codex's skills directory per the
[Codex skills docs](https://developers.openai.com/codex/skills); explicit
invocation is `$well-prompted`, or leave `allow_implicit_invocation` on (the
default) for automatic activation. No content changes are needed to run it on
Codex.

> Not independently verified: the exact on-disk skills path and any per-agent
> quirks of `npx skills add --agent codex` — confirm against the Codex docs
> above before relying on the install command.

## Maintenance & extending

- **Refresh a provider:** re-fetch the URLs in `models/<provider>.md`, update
  the content and the fetch date. Leave the core alone.
- **Add a provider:** drop in `models/<newprovider>.md` (same shape: overlay +
  sources + date) and add one row to the dispatch table in `SKILL.md`. The core
  does not change.
- **Guard the core:** null test — if a clause only applies to one model, it
  belongs in that model's file, not the core. The core must stay model-free.

Currently covers **OpenAI, Anthropic, and Gemini**. The structure is built to
grow to other providers without disturbing anything that already works.
