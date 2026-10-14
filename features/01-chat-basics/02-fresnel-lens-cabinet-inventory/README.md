# Chat basics · 02 · Fresnel lens cabinet inventory

The relief keeper at New Dungeness Light Station reads one cabinet list and asks one question: which drawer holds the spare bull's-eye, and how many chimneys are in drawer C.

**What it teaches**

- `RubyLLM.chat` opens the conversation. The model is an OpenRouter `:free` slug, so the call names `provider: :openrouter` and `assume_model_exists: true`.
- One `ask` returns one `RubyLLM::Message`.
- `content` is the inventory sentence. `role` is `:assistant`.
- `model` is the id string the provider returned. There is no `model_id` reader on the message. `chat.model.id` is the slug the chat was opened with.
- `tokens.input` and `tokens.output` are the counts for this turn.
- `finish_reason` is why the model stopped.

**Files**

| File | Role |
| --- | --- |
| [`lens_inventory.rb`](lens_inventory.rb) | Asks the cabinet question and reads the message |
| [`lens_inventory_test.rb`](lens_inventory_test.rb) | Replays the cassette and checks the readers |
| [`cassettes/lens_inventory.yml`](cassettes/lens_inventory.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/02-fresnel-lens-cabinet-inventory/lens_inventory.rb
bundle exec ruby features/01-chat-basics/02-fresnel-lens-cabinet-inventory/lens_inventory_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. The reply names drawer B, catalog NB-17, and the six chimneys under LC-6. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/02-fresnel-lens-cabinet-inventory/lens_inventory.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
