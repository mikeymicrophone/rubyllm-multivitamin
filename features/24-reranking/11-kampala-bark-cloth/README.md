# Reranking · 11 · Kampala bark cloth

The dye clerk in Kampala asks which bark-cloth panel is the morning dye
and sends no panels. Voyage still has to answer. The desk records the
error or the empty ranking.

**What it teaches**

- An empty document list is not a local ArgumentError the way a missing
  `model:` is.
- The provider may 400 or return zero results.
- Replay still needs a cassette if a request went out.

**Files**

| File | Role |
| --- | --- |
| [`bark_empty.rb`](bark_empty.rb) | Reranks an empty list |
| [`bark_empty_test.rb`](bark_empty_test.rb) | Checks the error or the zero count |
| [`cassettes/bark_empty.yml`](cassettes/bark_empty.yml) | The OpenRouter call, if one was sent |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/11-kampala-bark-cloth/bark_empty.rb
bundle exec ruby features/24-reranking/11-kampala-bark-cloth/bark_empty_test.rb
```

Replay needs no key. Re-record with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/11-kampala-bark-cloth/bark_empty.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter. Checked 16 October 2026.
