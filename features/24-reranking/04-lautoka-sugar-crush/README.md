# Reranking · 04 · Lautoka sugar crush

The mill clerk at Lautoka mill 2 asks which card is the overnight crush.
`provider: :openrouter` is explicit. Voyage puts mill 2 on top. Cohere
needs a key this catalog does not have; OpenRouter Voyage is the cheap path.

**What it teaches**

- Pass `provider: :openrouter` on the Voyage slug.
- `assume_model_exists: true` keeps a registry miss from raising.
- The crush card is still first.

**Files**

| File | Role |
| --- | --- |
| [`sugar_crush.rb`](sugar_crush.rb) | Reranks the mill cards |
| [`sugar_crush_test.rb`](sugar_crush_test.rb) | Checks mill 2 and the slug |
| [`cassettes/sugar_crush.yml`](cassettes/sugar_crush.yml) | The OpenRouter rerank call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/04-lautoka-sugar-crush/sugar_crush.rb
bundle exec ruby features/24-reranking/04-lautoka-sugar-crush/sugar_crush_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/04-lautoka-sugar-crush/sugar_crush.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter. Checked 16 October 2026.
