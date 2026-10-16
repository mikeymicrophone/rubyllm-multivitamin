# Embeddings · 09 · Sibiu painted-egg loft

The workshop keeper in the Upper Town ranks a question about the loft
against a paraphrase of the morning hygrometer and against a west-wall
eave repair. The paraphrase wins.

**What it teaches**

- A sentence and its paraphrase share a meaning the eave note does not.
- The query, the hygrometer, and the eave ride in one batch.
- Ranking is cosine on the three vectors. The test locks the order, not a
  particular score.

**Files**

| File | Role |
| --- | --- |
| [`egg_humidity.rb`](egg_humidity.rb) | Embeds the loft question, the hygrometer, and the eave |
| [`egg_humidity_test.rb`](egg_humidity_test.rb) | Replays the cassette |
| [`cassettes/egg_humidity.yml`](cassettes/egg_humidity.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/09-sibiu-egg-loft/egg_humidity_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/09-sibiu-egg-loft/egg_humidity_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
