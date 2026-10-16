# Reranking · 05 · Jos plateau strawberry

The bed clerk on the Jos plateau asks which bed is the ripe strawberry
for the morning crate. `voyageai/rerank-2.5` is not the lite default.
Bedrock `amazon.rerank-v1:0` needs AWS this catalog does not have.

**What it teaches**

- `model:` can be the full Voyage slug.
- The request body names `voyageai/rerank-2.5`, not lite.
- The ripe-bed card still lands first.

**Files**

| File | Role |
| --- | --- |
| [`strawberry_full.rb`](strawberry_full.rb) | Reranks the beds on the full slug |
| [`strawberry_full_test.rb`](strawberry_full_test.rb) | Checks the slug and bed 4 |
| [`cassettes/strawberry_full.yml`](cassettes/strawberry_full.yml) | The OpenRouter rerank call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/05-jos-plateau-strawberry/strawberry_full.rb
bundle exec ruby features/24-reranking/05-jos-plateau-strawberry/strawberry_full_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/05-jos-plateau-strawberry/strawberry_full.rb
```

**Model**

`voyageai/rerank-2.5` on OpenRouter. Checked 16 October 2026.
