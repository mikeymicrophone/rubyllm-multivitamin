# Reranking

`RubyLLM.rerank(query, documents, model:)` returns a `RubyLLM::Rerank`. Each `results` entry has `index`, `document`, and `score`. `top_n:` shrinks the response, not the work. There is no default model; `model:` is required. Usage lands on the same ledger as chat (`tokens.input`, `cost.total`) when the provider reports it.

Official reference: [Reranking](https://rubyllm.com/rerank/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.rerank(query, documents, model: "rerank-v3.5")`
- `rerank.results.first.index` / `document` / `score`
- `top_n:`
- `provider: :bedrock` / `:azure` / `:vertexai` / `:openrouter`
- `rerank.tokens` and `rerank.cost`

## Providers that can record it

Cohere `rerank-v3.5` (bills per search unit). OpenRouter Voyage (`voyageai/rerank-2.5-lite`). Bedrock `amazon.rerank-v1:0`. Azure deployed rerankers. Vertex AI `semantic-ranker-default-004` with `assume_model_exists: true`. OpenAI has no rerank API in 2.1.1. This catalog's cheap record path is Cohere `rerank-v3.5` or OpenRouter Voyage. Needs `COHERE_API_KEY` or `OPENROUTER_API_KEY`.

## Examples (0 of 13 bottled)

01. Bainbridge capital of the US — planned
02. Eagle Harbor top_n five — planned
03. Blakely Rock index back to records — planned
04. Alki Voyage on OpenRouter — planned
05. Duwamish Bedrock amazon.rerank — planned
06. Elliott Bay Vertex semantic-ranker — planned
07. Shilshole score cutoff — planned
08. Golden Gardens embed then rerank — planned
09. Meadow Point tokens.input — planned
10. Carkeek missing model: raises — planned
11. Richmond Beach empty documents — planned
12. Edmonds neighbor gem pipeline — planned
13. Possession Sound search desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
