# Models and providers · 13 · Maseru oxygen-run capstone

The highland clinic in Maseru filters chat clerks who can call tools,
puts `gpt-4.1-mini` on the radio with `assume_model_exists`, and asks
whether cylinder Oxy-4 can leave on the morning run to Thaba-Tseka.

**What it teaches**

- `chat_models.select { |model| model.supports?(:function_calling) }` is
  the capability filter. The free OpenRouter slug is on that board in the
  bundled registry.
- `RubyLLM.chat` names `provider:` and `assume_model_exists: true` so a
  later refresh can drop a slug overnight.
- The recorded ask uses `gpt-4.1-mini`, which `find` already knows, so
  assume keeps the real window and does not set a warning.
- One `ask` reads the fill card. `roles`, `finish_reason`, and `tokens`
  come off the message.

**Files**

| File | Role |
| --- | --- |
| [`oxygen_question.rb`](oxygen_question.rb) | Filters, assumes, asks the fill card |
| [`oxygen_question_test.rb`](oxygen_question_test.rb) | Replays the cassette |
| [`cassettes/oxygen_question.yml`](cassettes/oxygen_question.yml) | One Responses round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/13-maseru-oxygen-run/oxygen_question.rb
bundle exec ruby features/08-models-and-providers/13-maseru-oxygen-run/oxygen_question_test.rb
```

Both commands replay the cassette. No API key is required. Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/08-models-and-providers/13-maseru-oxygen-run/oxygen_question_test.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap allows.
Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free` answered the probe but inverted
a numeric card. Fallback:
`nvidia/nemotron-3-super-120b-a12b:free` via `LIVE_PROVIDER=openrouter`.
