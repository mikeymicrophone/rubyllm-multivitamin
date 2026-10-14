# Chat basics · 13 · Overnight watch handover across several boards

The outgoing clerk at Point Wilson hands the night tide board and the foghorn card to the relief on one chat, then answers whether to open the lens cabinet at low water. The follow-up needs both boards.

**What it teaches**

- `with_instructions` stays on the chat for the brief and the cabinet question.
- The first `ask` carries two boards. The second `ask` does not repeat them.
- `chat.messages` roles are system, user, assistant, user, assistant.
- `finish_reason`, `tokens.input`, and `tokens.output` are read off each reply. The cabinet question sends more input tokens because the brief is part of the transcript.

**Files**

| File | Role |
| --- | --- |
| [`watch_handover.rb`](watch_handover.rb) | Briefs the relief, then answers the cabinet question |
| [`watch_handover_test.rb`](watch_handover_test.rb) | Replays the cassette and checks both boards, the roles, and the tokens |
| [`cassettes/watch_handover.yml`](cassettes/watch_handover.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/01-chat-basics/13-overnight-watch-handover/watch_handover.rb
bundle exec ruby features/01-chat-basics/13-overnight-watch-handover/watch_handover_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs the same test with the rest of the bottled examples.

The cassette is a live recording of `nvidia/nemotron-3-super-120b-a12b:free`. Low water is 07:05, the horn is running, and the cabinet stays closed. Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/01-chat-basics/13-overnight-watch-handover/watch_handover.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any `sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
