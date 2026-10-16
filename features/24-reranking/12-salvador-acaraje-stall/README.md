# Reranking · 12 · Salvador acarajé stall

The market clerk in Salvador reranks four stall cards, then asks the
chat about the winner. Dona Lúcia fries at 07:20. This is the neighbor
pipeline shape without pgvector.

**What it teaches**

- Rerank, then `chat.ask` the winning document.
- `top_n: 1` is enough when the chat only needs one card.
- The cassette is rerank then Responses.

**Files**

| File | Role |
| --- | --- |
| [`acaraje_stall.rb`](acaraje_stall.rb) | Reranks, then briefs |
| [`acaraje_stall_test.rb`](acaraje_stall_test.rb) | Checks Lúcia and the two calls |
| [`cassettes/acaraje_stall.yml`](cassettes/acaraje_stall.yml) | Rerank then Responses |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/12-salvador-acaraje-stall/acaraje_stall.rb
bundle exec ruby features/24-reranking/12-salvador-acaraje-stall/acaraje_stall_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/12-salvador-acaraje-stall/acaraje_stall.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter, then `gpt-4.1-mini` on OpenAI.
Checked 16 October 2026.
