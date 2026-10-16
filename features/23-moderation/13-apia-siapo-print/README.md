# Moderation · 13 · Apia siapo print

The print desk in Apia screens three board slips. One threatens the
dye-house. The clerk holds that slip and briefs the clean siapo card.
Sina and 08:10 still land in the answer.

**What it teaches**

- Screen a batch. Skip the flagged slip. Brief the clean one.
- Outer `flagged?` is true. The chat still runs.
- The cassette is Moderations then Responses.

**Files**

| File | Role |
| --- | --- |
| [`siapo_desk.rb`](siapo_desk.rb) | Screens the slips, then briefs Sina |
| [`siapo_desk_test.rb`](siapo_desk_test.rb) | Checks the flags and the brief |
| [`cassettes/siapo_desk.yml`](cassettes/siapo_desk.yml) | Moderations then Responses |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/13-apia-siapo-print/siapo_desk.rb
bundle exec ruby features/23-moderation/13-apia-siapo-print/siapo_desk_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/13-apia-siapo-print/siapo_desk.rb
```

**Model**

`omni-moderation-latest` then `gpt-4.1-mini` on OpenAI. Checked 16 October 2026.
