# Reranking · 07 · Francistown agate cutoff

The tray clerk in Francistown asks which lot is the banded agate for the
cabochon tray. Voyage scores four lots. The desk keeps those within 0.15
of first place and drops the rest. Scores are not probabilities.

**What it teaches**

- Use scores as a cutoff you tune against your own lots.
- Do not compare scores across models.
- The banded lot stays. The glass imitants go.

**Files**

| File | Role |
| --- | --- |
| [`agate_cutoff.rb`](agate_cutoff.rb) | Reranks, then cuts |
| [`agate_cutoff_test.rb`](agate_cutoff_test.rb) | Checks the kept index |
| [`cassettes/agate_cutoff.yml`](cassettes/agate_cutoff.yml) | The OpenRouter rerank call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/07-francistown-agate-cutoff/agate_cutoff.rb
bundle exec ruby features/24-reranking/07-francistown-agate-cutoff/agate_cutoff_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/07-francistown-agate-cutoff/agate_cutoff.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter. Checked 16 October 2026.
