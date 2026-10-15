# Embeddings · 02 · Mandalay lacquer drawers

The atelier clerk on 26th Street embeds four drawer notes in one call: a
cracked bamboo cup blank, a hazy gold-leaf book, chipped horsehair
brushes, and a seized betel-box latch.

**What it teaches**

- Pass an `Array` of strings to `RubyLLM.embed`. That is one HTTP call.
- `embedding.vectors.length` matches the number of notes.
- Each inner array is 1536 floats on `text-embedding-3-small`.
- A single string would have flattened to one vector. The array keeps the
  extra dimension.

**Files**

| File | Role |
| --- | --- |
| [`lacquer_drawers.rb`](lacquer_drawers.rb) | Embeds the four drawer notes together |
| [`lacquer_drawers_test.rb`](lacquer_drawers_test.rb) | Replays the cassette |
| [`cassettes/lacquer_drawers.yml`](cassettes/lacquer_drawers.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/02-mandalay-lacquer-drawers/lacquer_drawers_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/02-mandalay-lacquer-drawers/lacquer_drawers_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-embed-1b:free` instead
and overwrites this cassette. Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
