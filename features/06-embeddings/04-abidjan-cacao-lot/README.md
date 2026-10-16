# Embeddings · 04 · Abidjan cacao lot

The shed clerk at Treichville embeds one ferment deviation twice: the plant
archive keeps the default 1536-wide vector, and the pocket ledger asks for
512 dimensions.

**What it teaches**

- `dimensions:` is sent only when it is set. The archive request omits the
  key and comes back 1536 long.
- The pocket request sends `"dimensions":512`, and `vectors.length` is 512.
- `text-embedding-3-small` accepts that cut. Input tokens stay the same
  because the note did not change.

**Files**

| File | Role |
| --- | --- |
| [`cacao_vectors.rb`](cacao_vectors.rb) | Embeds the deviation at two widths |
| [`cacao_vectors_test.rb`](cacao_vectors_test.rb) | Replays the cassette |
| [`cassettes/cacao_vectors.yml`](cassettes/cacao_vectors.yml) | Two live OpenAI round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/04-abidjan-cacao-lot/cacao_vectors_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/04-abidjan-cacao-lot/cacao_vectors_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
