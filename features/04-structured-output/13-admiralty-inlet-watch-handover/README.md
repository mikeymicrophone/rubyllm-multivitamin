# Structured output · 13 · Admiralty Inlet watch handover

The overnight watch at Point Wilson posts one handover. A tool reads the lens cabinet. The schema holds the tide, the boats, the lens crew, and the horn. A follow-up sets the horn to a three-second blast without leaving the schema. One Decisions call then asks whether the float is clear and which tender should leave.

**What it teaches**

- `with_schema` and `with_tools` share the chat. The first request sends both `text.format` and `tool_choice`.
- After the forced tool runs, RubyLLM clears `tool_choice`. The schema name `watch_handover` is still on the later requests.
- `shut` and the lens-crew sentence are not in the first `input`. They arrive from `lens_cabinet_latch`.
- The second `ask` stays under the same schema and changes `horn` from `not posted` to `three-second blast`.
- One `Judge` call sends a predicate and a choice together on `POST /v1/decisions`. At 07:10, with 0.4 ft of water, the float is not clear and the tender is `:neither`.

**Files**

| File | Role |
| --- | --- |
| [`watch_handover.rb`](watch_handover.rb) | Tool, schema, follow-up, then the judgment |
| [`watch_handover_test.rb`](watch_handover_test.rb) | Replays the cassette |
| [`cassettes/watch_handover.yml`](cassettes/watch_handover.yml) | Live OpenAI recording |

**Try it**

```sh
bundle exec ruby features/04-structured-output/13-admiralty-inlet-watch-handover/watch_handover_test.rb
```

Re-record. The judgment always uses `OPENAI_API_KEY` and `gpt-6-luna`:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/13-admiralty-inlet-watch-handover/watch_handover_test.rb
```

**Model**

The handover is `gpt-4.1-mini` on the Responses API. The float call is `gpt-6-luna` on Decisions.
