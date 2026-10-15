# Chat basics · 13 · Warsaw tram depot handover across several boards

The outgoing dispatcher at Zajezdnia Mokotów hands the night timetable and the frost card to the relief on one chat, then answers whether to open the paint locker at first outbound. The follow-up needs both boards.

**What it teaches**

- `with_instructions` stays on the chat for the brief and the locker question.
- The first `ask` carries two boards. The second `ask` does not repeat them.
- `chat.messages` roles are system, user, assistant, user, assistant.
- `finish_reason`, `tokens.input`, and `tokens.output` are read off each reply. The locker question sends more input tokens because the brief is part of the transcript.

**Files**

| File | Role |
| --- | --- |
| [`depot_handover.rb`](depot_handover.rb) | Briefs the relief, then answers the locker question |
| [`depot_handover_test.rb`](depot_handover_test.rb) | Replays the cassette and checks both boards, the roles, and the tokens |
| [`cassettes/depot_handover.yml`](cassettes/depot_handover.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/13-warsaw-tram-depot-handover/depot_handover.rb
bundle exec ruby features/01-chat-basics/13-warsaw-tram-depot-handover/depot_handover_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of OpenAI `gpt-4.1-mini`. First outbound is 07:05, the de-icer is running, and the paint locker stays closed. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/01-chat-basics/13-warsaw-tram-depot-handover/depot_handover.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter `:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback: `gpt-4o-mini`.
