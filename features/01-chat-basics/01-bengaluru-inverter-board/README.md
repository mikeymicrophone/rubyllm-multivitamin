# Chat basics · 01 · Bengaluru inverter board

The Iyer household in Jayanagar reads the posted inverter board for a
Bengaluru load-shedding morning. The clerk briefs two questions on one chat:
when Lakshmi can run the washing machine and when the twins can charge the
Chromebook cart, then whether to hail Uncle Ravi before Lakshmi's wash.

**What it teaches**

- `RubyLLM.chat` opens a conversation. The model is an OpenRouter `:free`
  slug, so the call names `provider: :openrouter` and
  `assume_model_exists: true`.
- `with_instructions` sets the clerk's system prompt. Both questions keep it.
- `ask` sends the transcript and returns a `RubyLLM::Message`.
- A second `ask` on the same chat sends the earlier turns back, so the aarti
  question can mention Lakshmi without repeating the board.
- `with_temperature` is set low because the brief has to stay with the board.
- `finish_reason`, `tokens.input`, `tokens.output`, and `cost.total` are read
  off each reply.
- `config.openai_use_system_role = true` so the wire role is `system`.
  RubyLLM's Chat Completions formatter sends `developer` until that flag is
  set, and OpenRouter expects `system`.

**Files**

| File | Role |
| --- | --- |
| [`inverter_briefing.rb`](inverter_briefing.rb) | Configures OpenRouter and asks the two household questions |
| [`inverter_briefing_test.rb`](inverter_briefing_test.rb) | Replays the cassette and checks the brief, the roles, and the usage |
| [`cassettes/inverter_briefing.yml`](cassettes/inverter_briefing.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/01-bengaluru-inverter-board/inverter_briefing.rb
bundle exec ruby features/01-chat-basics/01-bengaluru-inverter-board/inverter_briefing_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`.
The opening brief sends Lakshmi at about 10:46 and the twins at about 08:57.
The follow-up uses that 10:46 and tells the household not to hail Uncle Ravi
before Lakshmi's wash. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/01-bengaluru-inverter-board/inverter_briefing.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
