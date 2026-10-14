# Embeddings · 05 · Friday Harbor berth remarks

The berth desk at Friday Harbor embeds the same slip B4 remark twice: once
with `task_type: "RETRIEVAL_QUERY"` and once with `"RETRIEVAL_DOCUMENT"`,
plus a `title:`. OpenAI's embeddings encoder does not send those fields.

**What it teaches**

- `model:` selects the slug. Both requests name `text-embedding-3-small`.
- `task_type:` and `title:` are real arguments on `RubyLLM.embed`. OpenRouter
  would send `task_type` as `input_type`. OpenAI's Chat Completions embedding
  payload is `model`, `input`, and optional `dimensions` only.
- The two vectors of the same remark are cosine-identical to four places.
  The labels did not change the embedding.

**Files**

| File | Role |
| --- | --- |
| [`berth_remarks.rb`](berth_remarks.rb) | Embeds the B4 remark as query and as document |
| [`berth_remarks_test.rb`](berth_remarks_test.rb) | Replays the cassette |
| [`cassettes/berth_remarks.yml`](cassettes/berth_remarks.yml) | Two live OpenAI round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/05-friday-harbor-berth-remarks/berth_remarks_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/05-friday-harbor-berth-remarks/berth_remarks_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-embed-1b:free` and may
put `input_type` on the wire. Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
