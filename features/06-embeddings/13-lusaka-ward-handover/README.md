# Embeddings · 13 · Lusaka night-ward handover

The overnight clerk at University Teaching Hospital ranks a paediatric
question against four titled logs: the vitals board, the main autoclave
card, the kitchen nshima pot, and pharmacy window B4. The vitals board
is named first.

**What it teaches**

- A capstone search: one query, a small corpus, ranked titles, cosine on
  the stored vectors.
- Query and corpus ride in one batch so the cassette is one round-trip.
- A second play, with no API key, returns the same titles and the same
  scores. Replay does not call the model.

**Files**

| File | Role |
| --- | --- |
| [`ward_logs.rb`](ward_logs.rb) | Embeds the paediatric question with four ward logs |
| [`ward_logs_test.rb`](ward_logs_test.rb) | Replays the cassette, then plays it again |
| [`cassettes/ward_logs.yml`](cassettes/ward_logs.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/13-lusaka-ward-handover/ward_logs_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/13-lusaka-ward-handover/ward_logs_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
