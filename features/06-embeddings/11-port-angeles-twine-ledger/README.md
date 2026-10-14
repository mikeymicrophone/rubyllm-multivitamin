# Embeddings · 11 · Port Angeles net loft twine ledger

The loft clerk at Port Angeles writes three mending notes into a JSON
ledger with their vectors and the model slug. A later question about a
leadline splice searches that JSON without embedding the nets again. A
query on `text-embedding-3-large` is refused.

**What it teaches**

- Store the slug and the dimensions beside the vectors. JSON round-trips
  the floats.
- Search reloads the page and embeds only the question, on the same slug.
- Mixing `text-embedding-3-large` with a ledger stored as
  `text-embedding-3-small` raises `ArgumentError` before a second model is
  asked. The cassette has two calls, both on the small model.

**Files**

| File | Role |
| --- | --- |
| [`twine_ledger.rb`](twine_ledger.rb) | Embeds the loft notes, stores them, searches the JSON |
| [`twine_ledger_test.rb`](twine_ledger_test.rb) | Replays the cassette |
| [`cassettes/twine_ledger.yml`](cassettes/twine_ledger.yml) | Two live OpenAI round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/11-port-angeles-twine-ledger/twine_ledger_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/11-port-angeles-twine-ledger/twine_ledger_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
