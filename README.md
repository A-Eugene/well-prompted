# well-prompted

An [agent skill](https://vercel.com/docs/agent-resources/skills) that helps an
LLM write, improve, review, or port **prompts** for a specific target model.

It is built on one idea: **a prompting skill should only carry what the model
cannot already supply itself.**

---

## The problem this solves

Generic prompting advice — be clear and specific, give examples, provide
context, decompose the task, iterate against a test — is not a secret. It has
been on every provider's docs site for years, replicated across thousands of
tutorials, and it is *trained into* frontier models as disposition rather than
recalled as rule. Ask a current model to write a good prompt and you get that
advice applied whether or not a skill told it to. Restating it costs tokens and
changes nothing.

Three things are different, and they are what this skill carries:

- **Post-cutoff facts.** A model cannot know what shipped after it was trained.
  When a new model generation *reverses* prior guidance — as Claude Opus 5 did
  by self-verifying well enough that carried-over "verify your work"
  instructions now cause over-verification — the model's confident prior is
  exactly wrong.
- **Negative knowledge.** Practices that were standard for years and now return
  an error: prefilling the assistant turn (400 on Claude 4.6+), `budget_tokens`
  (400 on Claude 4.7+). A deeply-trained prior that is *wrong* is harder to fix
  than one that is merely absent.
- **Cross-provider counter-pull.** Knowing another provider's conventions is not
  the same as following them. A model shaped by Claude's XML idiom will reach
  for `<instructions>` blocks when writing a Gemini prompt, and reach for
  temperature tuning that Gemini 3.x now explicitly advises against. The
  provider file exists to override a default, not to add a fact.

## The design

```
well-prompted/
├── SKILL.md            # procedure + fetch-first rule + the three that bind
├── README.md           # this file
└── models/
    ├── anthropic.md    # Claude gotchas + calibration  (+ source URLs, fetch date)
    ├── openai.md       # OpenAI/GPT
    └── gemini.md       # Gemini
```

- **`SKILL.md`** holds the dispatch procedure and just **three** model-free
  principles — the ones that are *behavioral* (they change what gets done)
  rather than *informational* (they restate what a model already does):
  start from success criteria and a way to test; iterate one change at a time;
  never borrow one provider's tactic as universal.
- **`models/*.md`** are gotcha sheets, not tutorials. Each opens with its
  official **source URLs** and the **date fetched**, then leads with the errors
  a model's own priors will cause, followed by what genuinely differs.

### Fetch-first, so staleness fails safe

A stale skill is worse than no skill. Without one, a model's priors are
outdated *and hedged* — it will say "I think prefill still works, worth
checking." With a stale file carrying dates, sources, and tables, that hedge is
replaced by false confidence.

So step 2 of the procedure is a date comparison, not a judgment call:

> **If the target model is newer than the provider file's fetch date, fetch the
> live source before applying the file.**

"Re-fetch when you suspect drift" does not work — you cannot suspect drift you
have never heard of. Comparing a date needs no suspicion. The snapshot's job is
as much to *trigger* the fetch as to answer in its place.

### Why short files

Long files rot, because nobody refreshes them. Every provider file is kept small
enough to re-verify in one sitting, and techniques that are long to transcribe
are **named with their doc anchor** instead — enough to know to look, without
carrying a copy that silently ages.

## The dispatch table

| Target | What the file is for |
|---|---|
| **Anthropic / Claude** | Prefill and `budget_tokens` now 400; Opus 5 reverses verification and subagent advice; long-context ordering (documents top, query bottom); adaptive-thinking + effort API |
| **OpenAI / GPT** | `developer` > `user` hierarchy; Identity/Instructions/Examples/Context layout; reasoning-class is the branch, not the model name; cache-friendly prompt ordering |
| **Google / Gemini** | Always few-shot; **sampling-parameter tuning now advised against on Gemini 3.x**; thinking automatic on 2.5/3; XML now acceptable for system instructions |

Unknown target → the three principles, plus a fetch of that provider's guide,
and an explicit note that no overlay was available.

## Provenance

The model-specific files are snapshots of each provider's **official**
documentation, fetched **2026-08-03**:

- Anthropic — `platform.claude.com/docs/.../claude-prompting-best-practices` (+ per-model pages)
- OpenAI — `developers.openai.com/api/docs/guides/prompt-engineering`
- Google — `ai.google.dev/gemini-api/docs/prompting-strategies`

Each `models/*.md` restates its exact source URLs and fetch date.

## Installation & use

This skill follows the [vercel-labs/skills](https://github.com/vercel-labs/skills)
convention (a directory with a `SKILL.md`).

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
`well-prompted` is **Codex-compatible as-is** — its content is model-agnostic
and it ships the OpenAI/GPT overlay in `models/openai.md`. Install it into
Codex's skills directory per the
[Codex skills docs](https://developers.openai.com/codex/skills); explicit
invocation is `$well-prompted`, or leave `allow_implicit_invocation` on (the
default) for automatic activation.

> Not independently verified: the exact on-disk skills path and any per-agent
> quirks of `npx skills add --agent codex` — confirm against the Codex docs
> above before relying on the install command.

## Maintenance & extending

- **Refresh a provider:** re-fetch the URLs in `models/<provider>.md`, update
  the content *and* the date. The three principles stay put.
- **Add a provider:** drop in `models/<newprovider>.md` (same shape: sources +
  date, errors-your-priors-cause, then what differs) and add one row to the
  dispatch table.
- **Null test, ruthlessly.** If a clause states something a frontier model would
  already do unprompted, delete it. A line earns its place only by correcting an
  error, supplying a post-cutoff fact, or countering a cross-provider reflex.

Currently covers **Anthropic, OpenAI, and Gemini**.
