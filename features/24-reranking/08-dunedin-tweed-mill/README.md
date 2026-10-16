# Reranking · 08 · Dunedin tweed mill

The mill clerk in Dunedin embeds the kilt query, then reranks four loom
notes. This catalog has no neighbor gem and no pgvector. The retrieval
step is the embed; the ranking step is Voyage. Loom 3 is the Harris-weight
tweed.

**What it teaches**

- Embed the query, then rerank the candidate notes.
- The cassette is one embeddings POST and one rerank POST.
- `index` still points at the original array.

**Files**

| File | Role |
| --- | --- |
| [`tweed_mill.rb`](tweed_mill.rb) | Embeds, then reranks |
| [`tweed_mill_test.rb`](tweed_mill_test.rb) | Checks loom 3 and the two calls |
| [`cassettes/tweed_mill.yml`](cassettes/tweed_mill.yml) | Embeddings then rerank |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/08-dunedin-tweed-mill/tweed_mill.rb
bundle exec ruby features/24-reranking/08-dunedin-tweed-mill/tweed_mill_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/08-dunedin-tweed-mill/tweed_mill.rb
```

**Model**

`text-embedding-3-small` on OpenAI, then `voyageai/rerank-2.5-lite` on
OpenRouter. Checked 16 October 2026.
