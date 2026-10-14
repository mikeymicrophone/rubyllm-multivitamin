# Embeddings · 09 · Bremerton dry dock surveys

The dockmaster at Puget Sound Naval Shipyard ranks a question about water
over the sill against a paraphrase of the morning sounding and against a
west-wall crane repair. The paraphrase wins.

**What it teaches**

- A sentence and its paraphrase share a meaning the crane note does not.
- The query, the sounding, and the crane ride in one batch.
- Ranking is cosine on the three vectors. The test locks the order, not a
  particular score.

**Files**

| File | Role |
| --- | --- |
| [`sill_surveys.rb`](sill_surveys.rb) | Embeds the sill question, the sounding, and the crane |
| [`sill_surveys_test.rb`](sill_surveys_test.rb) | Replays the cassette |
| [`cassettes/sill_surveys.yml`](cassettes/sill_surveys.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/09-bremerton-dry-dock-surveys/sill_surveys_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/09-bremerton-dry-dock-surveys/sill_surveys_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
