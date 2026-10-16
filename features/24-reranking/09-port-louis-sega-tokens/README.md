# Reranking · 09 · Port Louis sega tokens

The set clerk in Port Louis ranks four sega cards. Voyage puts the
Saturday market set first. `tokens.input` and `cost.total` sit on the
same ledger as chat when the provider reports them. A nil count is still
a legal answer.

**What it teaches**

- Read usage off the `Rerank`, not off a chat message.
- Voyage may report tokens. Cohere bills per search unit and often
  leaves tokens nil.
- The market set is still first.

**Files**

| File | Role |
| --- | --- |
| [`sega_tokens.rb`](sega_tokens.rb) | Reranks and reads usage |
| [`sega_tokens_test.rb`](sega_tokens_test.rb) | Checks the index and the ledger |
| [`cassettes/sega_tokens.yml`](cassettes/sega_tokens.yml) | The OpenRouter rerank call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/09-port-louis-sega-tokens/sega_tokens.rb
bundle exec ruby features/24-reranking/09-port-louis-sega-tokens/sega_tokens_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/09-port-louis-sega-tokens/sega_tokens.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter. Checked 16 October 2026.
