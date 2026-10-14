# Embeddings · 06 · Neah Bay pilot reports

The Puget Sound pilot off Neah Bay files the Salish Grain boarding note
twice, then files the afternoon ebb. The two copies of the boarding note
sit on top of each other. The current note does not.

**What it teaches**

- The same string, twice in one batch, comes back as two vectors whose
  cosine is 1.0 within four places. This model is deterministic.
- That self-score is higher than the score against a different note from
  the same station.
- One call holds the note, its copy, and the current.

**Files**

| File | Role |
| --- | --- |
| [`pilot_reports.rb`](pilot_reports.rb) | Embeds the boarding note twice and the ebb |
| [`pilot_reports_test.rb`](pilot_reports_test.rb) | Replays the cassette |
| [`cassettes/pilot_reports.yml`](cassettes/pilot_reports.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/06-neah-bay-pilot-reports/pilot_reports_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/06-neah-bay-pilot-reports/pilot_reports_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
