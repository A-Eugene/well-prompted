#!/usr/bin/env bash
# PreToolUse(Edit|Write) hook: fire when the file being written IS instructions for a
# model.
#
# Why a hook rather than a line in the agent instructions: the skill's own trigger
# requires classifying the artifact, and such a file is almost always ABOUT something
# else — git layout, conventions, a workflow — so it gets classified by subject matter
# and the trigger is missed. Observed 2026-08-10: a SKILL.md was revised four times in
# one session without the skill being consulted, and the review that followed produced
# a model-generation fact (verbosity does not fall with effort on the current top model,
# so brevity must be asked for) that could not have been derived from the file. A hook
# fires on the artifact and does not depend on the classification step that failed.
set -u

read -r -d '' payload || true
path=$(printf '%s' "$payload" | python3 -c '
import json,sys
try: print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))
except Exception: print("")
' 2>/dev/null)
[ -n "$path" ] || exit 0

case "$path" in
  */SKILL.md|*/CLAUDE.md|*/AGENTS.md|*/.claude/*.md|*/agents/*.md|*/prompts/*.md)
    # additionalContext, not plain stdout: on PreToolUse a bare echo is only surfaced
    # in transcript mode, so the model — the one that needs to act on this — never
    # sees it. The JSON envelope is what reaches the model's context.
    msg="well-prompted: $path is instructions for a model, not documentation about one. Consult the well-prompted skill before editing it — that skill carries per-model facts (deprecated parameters, guidance that reversed this model generation, verbosity and effort calibration) which cannot be derived from the file being edited."
    python3 - "$msg" <<'PY'
import json, sys
print(json.dumps({"hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": sys.argv[1]}}))
PY
    ;;
esac
exit 0
