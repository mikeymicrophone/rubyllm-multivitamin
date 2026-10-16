# Reranking · 02 · Cali salsa plaza

The plaza clerk in Cali has eight salsa flyers and wants the five that
match tonight's sonoridad rehearsal. `top_n: 5` shrinks the response.
All eight flyers still go on the wire.

**What it teaches**

- `top_n:` limits how many results come back.
- The reranker still scores every flyer you sent.
- The request body keeps the full document list and `top_n`.

**Files**

| File | Role |
| --- | --- |
| [`salsa_plaza.rb`](salsa_plaza.rb) | Reranks eight flyers, keeps five |
| [`salsa_plaza_test.rb`](salsa_plaza_test.rb) | Checks the count and the body |
| [`cassettes/salsa_plaza.yml`](cassettes/salsa_plaza.yml) | The OpenRouter rerank call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/02-cali-salsa-plaza/salsa_plaza.rb
bundle exec ruby features/24-reranking/02-cali-salsa-plaza/salsa_plaza_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/02-cali-salsa-plaza/salsa_plaza.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter. Checked 16 October 2026.
