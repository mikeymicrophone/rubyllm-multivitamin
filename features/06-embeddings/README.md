# Embeddings

`RubyLLM.embed` turns text into vectors on `embedding.vectors`. An array of strings comes back as an array of vectors. Pass `model:`, and `provider:` when the id would otherwise resolve somewhere else. `dimensions:` cuts the vector when the model allows it. `task_type:` and `title:` are for models that distinguish a query from a document. `with:` embeds an image or other attachment beside one text. `sparse_vectors` is `nil` when the model returns none.

Compare with cosine similarity. Store nothing in this catalog unless the scenario is about the numbers themselves.

Official reference: [Embeddings](https://rubyllm.com/embeddings/).

## Models

These text cassettes were recorded on `text-embedding-3-small` with `provider: :openai` after the free OpenRouter embedding slugs answered `Rate limit exceeded: free-models-per-day`. The id was on OpenAI's models list on 14 October 2026. It is 1536 dimensions and accepts `dimensions:`. `LIVE=1 LIVE_PROVIDER=openai` records OpenAI again. `LIVE=1 LIVE_PROVIDER=openrouter` overwrites a text cassette with `nvidia/nemotron-3-embed-1b:free`. Replay ignores `LIVE_PROVIDER`.

The incubator-plaque cassette was recorded on paid `google/gemini-embedding-2` with `provider: :openrouter`, because `text-embedding-3-small` raises `UnsupportedAttachmentError` for a PNG and the free vision slug was past the same daily cap. `LIVE_PROVIDER` does not retarget that example.

Free OpenRouter fallbacks, when the cap allows: `nvidia/llama-nemotron-embed-vl-1b-v2:free` (text and image), then `nvidia/nemotron-3-embed-1b:free`, then `liquid/lfm-2.5-embedding-350m:free`. Audio, video, or PDF embeddings still need a paid model; the embeddings guide uses `google/gemini-embedding-2`. Pass `assume_model_exists: true` when the slug is missing from the bundled registry.

## Examples (13 of 13 bottled)

01. [Antananarivo vanilla cellar](01-antananarivo-vanilla-cellar/) — available
02. [Mandalay lacquer drawers](02-mandalay-lacquer-drawers/) — available
03. [Skopje filigree anneal faults](03-skopje-filigree-anneal/) — available
04. [Abidjan cacao lot](04-abidjan-cacao-lot/) — available
05. [Helsinki reserve slip](05-helsinki-reserve-slip/) — available
06. [Dublin Abbey prompt copy](06-dublin-prompt-copy/) — available
07. [Bishkek precinct tally cards](07-bishkek-tally-cards/) — available
08. [Entebbe incubator plaque](08-entebbe-incubator-card/) — available
09. [Sibiu painted-egg loft](09-sibiu-egg-loft/) — available
10. [Taipei nanguan hall hold](10-taipei-nanguan-hold/) — available
11. [Dhaka jamdani ledger](11-dhaka-jamdani-ledger/) — available
12. [Beirut galley proofs](12-beirut-galley-proofs/) — available
13. [Lusaka night-ward handover](13-lusaka-ward-handover/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | One string in, one flat vector out, length asserted |
| 02 | Several notes in one call, `vectors.length` matches |
| 03 | Cosine similarity: a fault report nearer its twin than a bake log |
| 04 | `dimensions:` set, and the vector length equals it |
| 05 | `task_type:` and `title:` accepted, omitted on OpenAI's wire |
| 06 | The same note embedded twice is closer to itself than to a different note |
| 07 | A blank string embeds; an empty array is `BadRequestError` |
| 08 | Image of an incubator plaque with `with:` on a vision embedding model |
| 09 | A loft sentence and its paraphrase rank above an unrelated eave note |
| 10 | Batch of hold notes, highest score named |
| 11 | Store vectors in JSON; do not mix models on the query |
| 12 | Near-duplicate galley blurbs cluster; shared words are not enough |
| 13 | Capstone: a small corpus, a query, ranked titles, no network on replay |
