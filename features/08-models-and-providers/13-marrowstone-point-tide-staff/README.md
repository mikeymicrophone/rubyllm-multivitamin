# Models and providers · 13 · Marrowstone Point tide-staff capstone

The keeper at Marrowstone Point Light, east of Port Townsend, filters
chat clerks who can call tools, puts `gpt-4.1-mini` on the radio with
`assume_model_exists`, and asks when the kelp skiff Nettie can clear the
eelgrass bar off Mystery Bay.

**What it teaches**

- `chat_models.select { |model| model.supports?(:function_calling) }` is
  the capability filter. The free OpenRouter slug is on that board in the
  bundled registry.
- `RubyLLM.chat` names `provider:` and `assume_model_exists: true` so a
  later refresh can drop a slug overnight.
- The recorded ask uses `gpt-4.1-mini`, which `find` already knows, so
  assume keeps the real window and does not set a warning.
- One `ask` reads the tide staff. `roles`, `finish_reason`, and `tokens`
  come off the message.

**Files**

| File | Role |
| --- | --- |
| [`staff_question.rb`](staff_question.rb) | Filters, assumes, asks the staff |
| [`staff_question_test.rb`](staff_question_test.rb) | Replays the cassette |
| [`cassettes/staff_question.yml`](cassettes/staff_question.yml) | One Responses round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/13-marrowstone-point-tide-staff/staff_question.rb
bundle exec ruby features/08-models-and-providers/13-marrowstone-point-tide-staff/staff_question_test.rb
```

Both commands replay the cassette. No API key is required. Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/08-models-and-providers/13-marrowstone-point-tide-staff/staff_question_test.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap allows.
Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`nvidia/nemotron-3-super-120b-a12b:free` via `LIVE_PROVIDER=openrouter`.
