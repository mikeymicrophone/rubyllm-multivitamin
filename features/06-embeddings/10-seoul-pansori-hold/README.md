# Embeddings · 10 · Seoul pansori hall hold

The house clerk at the National Gugak Center ranks a question about a
held Chunhyang sitting against three posted notes: a cracked janggu
drumhead, a foyer tea urn, and a ticket window at the annex. The
drumhead is named first.

**What it teaches**

- One batch holds the query and the corpus.
- The clerk names the winning title, not an index.
- Scores are sorted descending. The test locks the winner and the order of
  the top two scores.

**Files**

| File | Role |
| --- | --- |
| [`hall_holds.rb`](hall_holds.rb) | Embeds the hold question with three hall notes |
| [`hall_holds_test.rb`](hall_holds_test.rb) | Replays the cassette |
| [`cassettes/hall_holds.yml`](cassettes/hall_holds.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/10-seoul-pansori-hold/hall_holds_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/10-seoul-pansori-hold/hall_holds_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
