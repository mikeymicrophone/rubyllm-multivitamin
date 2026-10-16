# Evaluations · 09 · Yazd windcatcher JSON report tokens

The draft clerk at a Yazd windcatcher house files the 10:20 draw for Shirin.
`report.save` writes tokens and cost beside the verdicts.

**What it teaches**

- `report.save` writes a JSON file with `tokens.input_tokens` and `cost`.
- `report.tokens` sums the clerk and the grader.
- The saved `id` matches `report.id`.

**Files**

| File | Role |
| --- | --- |
| [`windcatcher_draft.rb`](windcatcher_draft.rb) | Runs the draft case and writes the JSON report |
| [`windcatcher_draft.yml`](windcatcher_draft.yml) | The draft-window case |
| [`windcatcher_draft_test.rb`](windcatcher_draft_test.rb) | Replays the cassette and checks the saved tokens |
| [`cassettes/windcatcher_draft.yml`](cassettes/windcatcher_draft.yml) | Clerk and grader round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/09-yazd-windcatcher-draft/windcatcher_draft.rb
bundle exec ruby features/20-evaluations/09-yazd-windcatcher-draft/windcatcher_draft_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/09-yazd-windcatcher-draft/windcatcher_draft.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
