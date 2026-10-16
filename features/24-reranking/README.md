# Reranking

`RubyLLM.rerank(query, documents, model:)` returns a `RubyLLM::Rerank`. Each `results` entry has `index`, `document`, and `score`. `top_n:` shrinks the response, not the work. There is no default model; `model:` is required. Usage lands on the same ledger as chat (`tokens.input`, `cost.total`) when the provider reports it.

Official reference: [Reranking](https://rubyllm.com/rerank/).

## Models

OpenAI has no rerank API in 2.1.1. This catalog records OpenRouter Voyage `voyageai/rerank-2.5-lite`, and `voyageai/rerank-2.5` when a slot needs the full slug. Briefs after a rank use `gpt-4.1-mini`. The Dunedin mill also records OpenAI `text-embedding-3-small`. Cohere, Bedrock, Azure, and Vertex need keys or projects this catalog does not have. Checked 16 October 2026.

## Examples (13 of 13 bottled)

01. [Livingstone mukwa yard](01-livingstone-mukwa-yard/) — available
02. [Cali salsa plaza](02-cali-salsa-plaza/) — available
03. [Arequipa sillar quarry](03-arequipa-sillar-quarry/) — available
04. [Lautoka sugar crush](04-lautoka-sugar-crush/) — available
05. [Jos plateau strawberry](05-jos-plateau-strawberry/) — available
06. [Cuenca toquilla hat](06-cuenca-toquilla-hat/) — available
07. [Francistown agate cutoff](07-francistown-agate-cutoff/) — available
08. [Dunedin tweed mill](08-dunedin-tweed-mill/) — available
09. [Port Louis sega tokens](09-port-louis-sega-tokens/) — available
10. [Nadi ginger shed](10-nadi-ginger-shed/) — available
11. [Kampala bark cloth](11-kampala-bark-cloth/) — available
12. [Salvador acarajé stall](12-salvador-acaraje-stall/) — available
13. [Rotorua hāngī pit](13-rotorua-hangi-pit/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Basic rank, first `index` / `document` / `score` |
| 02 | `top_n: 5` of eight flyers |
| 03 | `index` back to quarry structs |
| 04 | Explicit `provider: :openrouter` on Voyage lite |
| 05 | Full `voyageai/rerank-2.5` slug |
| 06 | Spanish query, mixed-language cards |
| 07 | Score cutoff against first place |
| 08 | Embed the query, then rerank |
| 09 | `tokens.input` and `cost.total` |
| 10 | Missing `model:` raises `ArgumentError` locally |
| 11 | Empty document list |
| 12 | Rank, then `chat.ask` the winner |
| 13 | Capstone: eight pits, `top_n: 3`, brief |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
