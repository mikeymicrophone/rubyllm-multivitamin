# Embeddings · 12 · Juan de Fuca chart blurbs

The mate correcting NOAA chart 18465 clusters two near-duplicate notes about
lighted bell buoy DH moving 300 yards northwest, and keeps a third blurb
that shares the buoy name but talks about the fog signal.

**What it teaches**

- Greedy clustering on cosine, with a floor of 0.8, groups the two move
  notes as duplicates.
- Shared words (`chart 18465`, `buoy DH`) are not enough. The horn blurb
  stays in its own cluster.
- One batch embeds all three blurbs.

**Files**

| File | Role |
| --- | --- |
| [`chart_blurbs.rb`](chart_blurbs.rb) | Embeds three chart blurbs and clusters them |
| [`chart_blurbs_test.rb`](chart_blurbs_test.rb) | Replays the cassette |
| [`cassettes/chart_blurbs.yml`](cassettes/chart_blurbs.yml) | Live OpenAI recording of `text-embedding-3-small` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/06-embeddings/12-juan-de-fuca-chart-blurbs/chart_blurbs_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/06-embeddings/12-juan-de-fuca-chart-blurbs/chart_blurbs_test.rb
```

Do not hand-author the cassette.

**Model**

Recorded on `text-embedding-3-small` with `provider: :openai`. Fallback:
`nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`.
