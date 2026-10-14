# Embeddings · 10 · Port Townsend ferry delays

The slip clerk at Port Townsend ranks a question about a held Coupeville
sailing against three posted notes: a southwest crosswind, a galley cooler
on Kennewick, and a tide window at the Coupeville apron. The crosswind is
named first.

**What it teaches**

- One batch holds the query and the corpus.
- The watch names the winning title, not an index.
- Scores are sorted descending. The test locks the winner and the order of
  the top two scores.

**Files**

| File | Role |
| --- | --- |
| [`ferry_delays.rb`](ferry_delays.rb) | Embeds the delay question with three slip notes |
| [`ferry_delays_test.rb`](ferry_delays_test.rb) | Replays the cassette |
| [`cassettes/ferry_delays.yml`](cassettes/ferry_delays.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/10-port-townsend-ferry-delays/ferry_delays_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/10-port-townsend-ferry-delays/ferry_delays_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
