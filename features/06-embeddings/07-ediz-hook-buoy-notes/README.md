# Embeddings · 07 · Ediz Hook buoy service notes

The buoy tender off Ediz Hook files a blank service card, then an empty
stack of cards. OpenAI embeds the blank string. The empty array is HTTP 400.

**What it teaches**

- `RubyLLM.embed("")` returns a 1536-wide vector. `tokens.input` is 0 and
  `cost.total` is 0. The vector is not all zeros.
- `RubyLLM.embed([])` raises `RubyLLM::BadRequestError` with
  `Invalid 'input': input cannot be an empty array.`
- The cassette holds both round-trips: HTTP 200 for `""`, HTTP 400 for `[]`.

**Files**

| File | Role |
| --- | --- |
| [`buoy_notes.rb`](buoy_notes.rb) | Embeds a blank card, then an empty stack |
| [`buoy_notes_test.rb`](buoy_notes_test.rb) | Replays the cassette |
| [`cassettes/buoy_notes.yml`](cassettes/buoy_notes.yml) | One 200 and one 400 on OpenAI |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/07-ediz-hook-buoy-notes/buoy_notes_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/07-ediz-hook-buoy-notes/buoy_notes_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
