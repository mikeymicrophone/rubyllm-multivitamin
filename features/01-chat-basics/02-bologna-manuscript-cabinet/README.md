# Chat basics · 02 · Bologna manuscript cabinet

The relief librarian at the Archiginnasio in Bologna reads one cabinet list and asks one question: which drawer holds the spare vellum folio, and how many cradles are in drawer C.

**What it teaches**

- `RubyLLM.chat` opens the conversation. The model is OpenAI `gpt-4.1-mini`, so the call names `provider: :openai`.
- One `ask` returns one `RubyLLM::Message`.
- `content` is the inventory sentence. `role` is `:assistant`.
- `model` is the id string the provider returned. There is no `model_id` reader on the message. `chat.model.id` is the slug the chat was opened with.
- `tokens.input` and `tokens.output` are the counts for this turn.
- `finish_reason` is why the model stopped.

**Files**

| File | Role |
| --- | --- |
| [`manuscript_inventory.rb`](manuscript_inventory.rb) | Asks the cabinet question and reads the message |
| [`manuscript_inventory_test.rb`](manuscript_inventory_test.rb) | Replays the cassette and checks the readers |
| [`cassettes/manuscript_inventory.yml`](cassettes/manuscript_inventory.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/02-bologna-manuscript-cabinet/manuscript_inventory.rb
bundle exec ruby features/01-chat-basics/02-bologna-manuscript-cabinet/manuscript_inventory_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of OpenAI `gpt-4.1-mini`. The reply names drawer B, catalog VF-17, and the six cradles under BC-6. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/01-chat-basics/02-bologna-manuscript-cabinet/manuscript_inventory.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter `:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback: `gpt-4o-mini`.
