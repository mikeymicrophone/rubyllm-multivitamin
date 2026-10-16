# Reranking · 03 · Arequipa sillar quarry

The quarry clerk in Arequipa keeps four sillar bays as structs. Voyage
ranks the notes. `index` points at bay C in the original array, not at
first place in the ranked list.

**What it teaches**

- `index` maps a result back to the record you sent.
- Keep the structs. Do not parse the ranked document for the bay letter.
- The winning note still names the cathedral lintel.

**Files**

| File | Role |
| --- | --- |
| [`sillar_quarry.rb`](sillar_quarry.rb) | Reranks the notes, reads the struct |
| [`sillar_quarry_test.rb`](sillar_quarry_test.rb) | Checks bay C |
| [`cassettes/sillar_quarry.yml`](cassettes/sillar_quarry.yml) | The OpenRouter rerank call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/24-reranking/03-arequipa-sillar-quarry/sillar_quarry.rb
bundle exec ruby features/24-reranking/03-arequipa-sillar-quarry/sillar_quarry_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/24-reranking/03-arequipa-sillar-quarry/sillar_quarry.rb
```

**Model**

`voyageai/rerank-2.5-lite` on OpenRouter. Checked 16 October 2026.
