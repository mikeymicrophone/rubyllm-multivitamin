# Chat basics · 01 · Point Wilson tide board

The incoming watch at Point Wilson Light Station reads the posted tide board
for Admiralty Inlet. The tide clerk briefs two questions on one chat: when
the foghorn tender Alden and the cannery tender Retort can leave the float,
then whether to hail the Fresnel lens crew before Alden sails.

**What it teaches**

- `RubyLLM.chat` opens a conversation. The model is an OpenRouter `:free`
  slug, so the call names `provider: :openrouter` and
  `assume_model_exists: true`.
- `with_instructions` sets the clerk's system prompt. Both questions keep it.
- `ask` sends the transcript and returns a `RubyLLM::Message`.
- A second `ask` on the same chat sends the earlier turns back, so the lens
  question can mention Alden without repeating the board.
- `with_temperature` is set low because the brief has to stay with the board.
- `finish_reason`, `tokens.input`, `tokens.output`, and `cost.total` are read
  off each reply.
- `config.openai_use_system_role = true` so the wire role is `system`.
  RubyLLM's Chat Completions formatter sends `developer` until that flag is
  set, and OpenRouter expects `system`.

**Files**

| File | Role |
| --- | --- |
| [`tide_briefing.rb`](tide_briefing.rb) | Configures OpenRouter and asks the two watch questions |
| [`tide_briefing_test.rb`](tide_briefing_test.rb) | Replays the cassette and checks the brief, the roles, and the usage |
| [`cassettes/tide_briefing.yml`](cassettes/tide_briefing.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/01-point-wilson-tide-board/tide_briefing.rb
bundle exec ruby features/01-chat-basics/01-point-wilson-tide-board/tide_briefing_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette was hand-authored. The request bodies are the JSON RubyLLM
2.1.1's OpenRouter Chat Completions encoder produced for this script. The
response bodies follow OpenRouter's chat completion shape, including
`usage.cost`, and the wording was written to satisfy the clerk's
instructions. It is not a recording of a live model. Re-record it before
treating the sentences as something a model actually said:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/01-point-wilson-tide-board/tide_briefing.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
