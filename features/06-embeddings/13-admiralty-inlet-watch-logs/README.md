# Embeddings · 13 · Admiralty Inlet watch logs

The overnight clerk at Admiralty Inlet ranks a kelp-ledge question against
four titled logs: the Point Wilson tide board, the Cape Disappointment horn
card, the Anacortes morning cook, and Friday Harbor slip B4. The tide board
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
| [`watch_logs.rb`](watch_logs.rb) | Embeds the kelp-ledge question with four station logs |
| [`watch_logs_test.rb`](watch_logs_test.rb) | Replays the cassette, then plays it again |
| [`cassettes/watch_logs.yml`](cassettes/watch_logs.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/13-admiralty-inlet-watch-logs/watch_logs_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/13-admiralty-inlet-watch-logs/watch_logs_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
