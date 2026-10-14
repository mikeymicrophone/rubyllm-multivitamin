# Embeddings · 02 · New Dungeness lens cabinet defects

The lens keeper at New Dungeness Light Station embeds four cabinet notes in
one call: a cracked center prism, a hazy bull's-eye, chipped chimneys, and
a seized clockwork chain.

**What it teaches**

- Pass an `Array` of strings to `RubyLLM.embed`. That is one HTTP call.
- `embedding.vectors.length` matches the number of notes.
- Each inner array is 1536 floats on `text-embedding-3-small`.
- A single string would have flattened to one vector. The array keeps the
  extra dimension.

**Files**

| File | Role |
| --- | --- |
| [`lens_defects.rb`](lens_defects.rb) | Embeds the four cabinet notes together |
| [`lens_defects_test.rb`](lens_defects_test.rb) | Replays the cassette |
| [`cassettes/lens_defects.yml`](cassettes/lens_defects.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/02-new-dungeness-lens-defects/lens_defects_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/02-new-dungeness-lens-defects/lens_defects_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-embed-1b:free` instead
and overwrites this cassette. Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
