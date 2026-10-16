# Batches · 10 · Cali salsa-shoe Rails batch table

The last clerk at the Cali salsa-shoe loft files 15 pairs for Camila.
`ruby_llm_batches` keeps the provider id and the last-log row.

**What it teaches**

- `ruby_llm_batches` stores `provider_batch_id` after `RubyLLM.batch`.
- ActiveRecord chats with `ask_later` persist into that row's `chat_ids`.

**Files**

| File | Role |
| --- | --- |
| [`salsa_shoe.rb`](salsa_shoe.rb) | Boots the last log, stages the card, submits the batch |
| [`salsa_shoe_test.rb`](salsa_shoe_test.rb) | Replays the cassette and reads the AR row |
| [`cassettes/salsa_shoe.yml`](cassettes/salsa_shoe.yml) | Upload and create, with the Rails store on |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/10-cali-salsa-shoe/salsa_shoe.rb
bundle exec ruby features/21-batches/10-cali-salsa-shoe/salsa_shoe_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/10-cali-salsa-shoe/salsa_shoe.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
