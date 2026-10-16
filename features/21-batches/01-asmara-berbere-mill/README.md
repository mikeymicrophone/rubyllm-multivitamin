# Batches · 01 · Asmara berbere-mill staged briefs

The mill clerk in Asmara stages two berbere cards with `ask_later`, then
`RubyLLM.batch` files them as one provider batch.

**What it teaches**

- `ask_later` stages a chat without contacting the provider.
- `RubyLLM.batch` submits the staged chats and returns a `Batch` with an id.
- `status` is `:pending` until the provider finishes.

**Files**

| File | Role |
| --- | --- |
| [`berbere_mill.rb`](berbere_mill.rb) | Stages two mill cards and submits the batch |
| [`berbere_mill_test.rb`](berbere_mill_test.rb) | Replays the cassette and checks the id |
| [`cassettes/berbere_mill.yml`](cassettes/berbere_mill.yml) | JSONL upload and batch create |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/01-asmara-berbere-mill/berbere_mill.rb
bundle exec ruby features/21-batches/01-asmara-berbere-mill/berbere_mill_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/01-asmara-berbere-mill/berbere_mill.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
