# Embeddings

`RubyLLM.embed` turns text into vectors on `embedding.vectors`. An array of strings comes back as an array of vectors. Pass `model:`, and `provider:` when the id would otherwise resolve somewhere else. `dimensions:` cuts the vector when the model allows it. `task_type:` and `title:` are for models that distinguish a query from a document. `with:` embeds an image or other attachment beside one text. `sparse_vectors` is `nil` when the model returns none.

Compare with cosine similarity. Store nothing in this catalog unless the scenario is about the numbers themselves.

Official reference: [Embeddings](https://rubyllm.com/embeddings/).

## Free models

`nvidia/llama-nemotron-embed-vl-1b-v2:free` takes text and image. Text-only fallbacks: `nvidia/nemotron-3-embed-1b:free`, then `liquid/lfm-2.5-embedding-350m:free`. Audio, video, or PDF embeddings need a paid model; the embeddings guide uses `google/gemini-embedding-2` on OpenRouter. No `:free` embedding model advertised those inputs on 14 October 2026. Pass `assume_model_exists: true` when the slug is missing from the bundled registry.

## Examples (0 of 13 bottled)

01. Similar tide notes from the Point Wilson desk — planned
02. Lens cabinet defect notes — planned
03. Foghorn fault reports — planned
04. Retort deviation notes — planned
05. Berth remarks at Friday Harbor — planned
06. Pilot reports off Neah Bay — planned
07. Buoy service notes — planned
08. Weather round narratives — planned
09. Dry dock survey sentences — planned
10. Ferry delay notes — planned
11. Net loft repair notes — planned
12. Chart correction blurbs — planned
13. Rank a watch question against a stack of station logs — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One string in, one vector out, length asserted |
| 02 | Several notes in one call, `vectors.length` matches |
| 03 | Cosine similarity: a fault report nearer its twin than a cook log |
| 04 | `dimensions:` set, and the vector length equals it when the model accepts it |
| 05 | Query versus document `task_type:` where the model has one |
| 06 | The same note embedded twice is closer to itself than to a different note |
| 07 | A miss: an empty string and the error the provider returns |
| 08 | Image of a barometer card with `with:` on the vision embedding model |
| 09 | A survey sentence and its paraphrase rank above an unrelated sill measurement |
| 10 | Batch of delay notes, highest score named |
| 11 | Do not mix models: the test embeds the corpus and the query with one slug |
| 12 | A blurb that shares words but not meaning ranks below a true match |
| 13 | Capstone: a small corpus, a query, ranked titles, no network on replay |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
