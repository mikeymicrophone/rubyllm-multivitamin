# Reranking · 06 · Cuenca toquilla hat

The hat clerk in Cuenca asks, in Spanish, which block is the fino
toquilla for the gala hat. Voyage ranks mixed Spanish and English cards.
The fino block still lands first. Vertex semantic-ranker needs GCP this
catalog does not have.

**What it teaches**

- The query language does not have to match every card.
- `index` still points at the original array.
- `assume_model_exists` is not required here; the Voyage slug is listed.

**Files**

| File | Role |
| --- | --- |
| [`toquilla_hat.rb`](toquilla_hat.rb) | Reranks the blocks |
| [`toquilla_hat_test.rb`](toquilla_hat_test.rb) | Checks the fino index |
| [`cassettes/toquilla_hat.yml`](cassettes/toquilla_hat.yml) | The OpenRouter rerank call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/06-cuenca-toquilla-hat/toquilla_hat.rb
bundle exec ruby features/24-reranking/06-cuenca-toquilla-hat/toquilla_hat_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/06-cuenca-toquilla-hat/toquilla_hat.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter. Checked 16 October 2026.
