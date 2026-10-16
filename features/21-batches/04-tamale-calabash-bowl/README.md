# Batches · 04 · Tamale calabash-bowl tool then rebatch

The bowl clerk in Tamale reads bench TM-4 through `posted_calabash_card`,
then stages the follow-up with `ask_later` and submits it as a batch.

**What it teaches**

- A chat must be awaiting the model before it can enter a batch.
- After a live tool round, `ask_later` stages the next turn for `RubyLLM.batch`.

**Files**

| File | Role |
| --- | --- |
| [`calabash_bowl.rb`](calabash_bowl.rb) | Runs the tool, stages the follow-up, submits the batch |
| [`calabash_bowl_test.rb`](calabash_bowl_test.rb) | Replays the cassette and checks the tool role |
| [`cassettes/calabash_bowl.yml`](cassettes/calabash_bowl.yml) | Tool chat, JSONL upload, and batch create |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/04-tamale-calabash-bowl/calabash_bowl.rb
bundle exec ruby features/21-batches/04-tamale-calabash-bowl/calabash_bowl_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/04-tamale-calabash-bowl/calabash_bowl.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
