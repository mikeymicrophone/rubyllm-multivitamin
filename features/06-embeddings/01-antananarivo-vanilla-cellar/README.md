# Embeddings · 01 · Antananarivo vanilla cellar

The Razafy household in Isotry embeds one posted curing note: which crate
Noro opens, when Hery can take the first braid, and when Lalao clears the
sweating ledge. The result is a single vector the later harvest can keep
with the chalk.

**What it teaches**

- `RubyLLM.embed` takes one string and returns a `RubyLLM::Embedding`.
- `embedding.vectors` is a flat `Array` of `Float`, 1536 long on
  `text-embedding-3-small`. It is not an array of vectors.
- `embedding.model` is the slug. `sparse_vectors` is `nil` on this model.
- `tokens.input` and `cost.total` come off the same object. OpenAI reports
  both. `tokens.output` is not used for embeddings.

**Files**

| File | Role |
| --- | --- |
| [`curing_note.rb`](curing_note.rb) | Embeds the posted Isotry curing note |
| [`curing_note_test.rb`](curing_note_test.rb) | Replays the cassette |
| [`cassettes/curing_note.yml`](cassettes/curing_note.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/01-antananarivo-vanilla-cellar/curing_note_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/01-antananarivo-vanilla-cellar/curing_note_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-embed-1b:free` instead
and overwrites this cassette. The helper strips `Authorization` and
`OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. The id was on
OpenAI's models list on 14 October 2026. The free OpenRouter embedding slugs
were past the daily cap that evening, so this feature bottles on OpenAI.
Fallback: `nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`,
then `liquid/lfm-2.5-embedding-350m:free`.
