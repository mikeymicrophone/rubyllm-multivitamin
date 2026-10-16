# Reranking · 01 · Livingstone mukwa yard

The timber clerk in Livingstone asks which stack is the mukwa for the
school desks. The pine and teak cards sit first. Voyage puts the mukwa
card on top. `index` is 2, the slot in the array that was sent.

**What it teaches**

- `RubyLLM.rerank` orders documents by relevance to a query.
- `results.first` has `index`, `document`, and `score`.
- `model:` is required. There is no default rerank model.

**Files**

| File | Role |
| --- | --- |
| [`mukwa_yard.rb`](mukwa_yard.rb) | Reranks the four stacks |
| [`mukwa_yard_test.rb`](mukwa_yard_test.rb) | Checks the mukwa index |
| [`cassettes/mukwa_yard.yml`](cassettes/mukwa_yard.yml) | The OpenRouter rerank call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/01-livingstone-mukwa-yard/mukwa_yard.rb
bundle exec ruby features/24-reranking/01-livingstone-mukwa-yard/mukwa_yard_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/01-livingstone-mukwa-yard/mukwa_yard.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter. Checked 16 October 2026.
