# Embeddings · 12 · Beirut galley proofs

The compositor at a Hamra press clusters two near-duplicate notes about
folio DH moving 300 lines northwest, and keeps a zaatar catering card
that borrowed the same tokens (`DH`, `18465`, `300`, `northwest`).

**What it teaches**

- Greedy clustering on cosine, with a floor of 0.8, groups the two move
  notes as duplicates.
- Shared tokens are not enough. The catering card stays in its own cluster
  and ranks below either move note against a “where did DH move” query.
- One batch embeds the query and the three blurbs.

**Files**

| File | Role |
| --- | --- |
| [`galley_proofs.rb`](galley_proofs.rb) | Embeds three galley blurbs and clusters them |
| [`galley_proofs_test.rb`](galley_proofs_test.rb) | Replays the cassette |
| [`cassettes/galley_proofs.yml`](cassettes/galley_proofs.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/12-beirut-galley-proofs/galley_proofs_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/12-beirut-galley-proofs/galley_proofs_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
