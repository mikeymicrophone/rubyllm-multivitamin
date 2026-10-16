# Embeddings · 10 · Taipei nanguan hall hold

The house clerk at a Dihua Street nanguan hall ranks a question about a
held Chen San Wu Niang sitting against three posted notes: a cracked pipa
soundboard, a foyer oolong urn, and a ticket window at the annex. The
soundboard is named first.

**What it teaches**

- Immutable `Data` notes and rankings pair with vectors through `zip`; a lazy map scores the pairs before sorting.
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
bundle exec ruby features/06-embeddings/10-taipei-nanguan-hold/hall_holds_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/10-taipei-nanguan-hold/hall_holds_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
