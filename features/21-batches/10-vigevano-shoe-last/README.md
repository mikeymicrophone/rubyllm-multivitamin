# Batches · 10 · Vigevano shoe-last Rails batch table

The last clerk at the Vigevano shoe loft files 15 pairs for Giada.
`ruby_llm_batches` keeps the provider id and the last-log row.

**What it teaches**

- `ruby_llm_batches` stores `provider_batch_id` after `RubyLLM.batch`.
- ActiveRecord chats with `ask_later` persist into that row's `chat_ids`.

**Files**

| File | Role |
| --- | --- |
| [`shoe_last.rb`](shoe_last.rb) | Boots the last log, stages the card, submits the batch |
| [`shoe_last_test.rb`](shoe_last_test.rb) | Replays the cassette and reads the AR row |
| [`cassettes/shoe_last.yml`](cassettes/shoe_last.yml) | Upload and create, with the Rails store on |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/10-vigevano-shoe-last/shoe_last.rb
bundle exec ruby features/21-batches/10-vigevano-shoe-last/shoe_last_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/10-vigevano-shoe-last/shoe_last.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
