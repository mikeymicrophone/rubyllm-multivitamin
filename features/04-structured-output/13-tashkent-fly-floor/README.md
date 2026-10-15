# Structured output · 13 · Tashkent fly-floor handover

The overnight fly floor at the Alisher Navoi Theatre posts one handover. A tool reads the costume cabinet. The schema holds the curtain, the companies, the fly crew, and the overture. A follow-up sets the overture to a three-second blast without leaving the schema. One Decisions call then asks whether the deck is clear and which company should leave.

**What it teaches**

- `with_schema` and `with_tools` share the chat. The first request sends both `text.format` and `tool_choice`.
- After the forced tool runs, RubyLLM clears `tool_choice`. The schema name `fly_handover` is still on the later requests.
- `shut` and the dresser sentence are not in the first `input`. They arrive from `costume_cabinet_latch`.
- The second `ask` stays under the same schema and changes `overture` from `not posted` to `three-second blast`.
- One `Judge` call sends a predicate and a choice together on `POST /v1/decisions`. At 07:10, with 0.4 m of fly, the deck is not clear and the company is `:neither`.

**Files**

| File | Role |
| --- | --- |
| [`fly_handover.rb`](fly_handover.rb) | Tool, schema, follow-up, then the judgment |
| [`fly_handover_test.rb`](fly_handover_test.rb) | Replays the cassette |
| [`cassettes/fly_handover.yml`](cassettes/fly_handover.yml) | Live recording |

**Try it**

```sh
bundle exec ruby features/04-structured-output/13-tashkent-fly-floor/fly_handover_test.rb
```

Re-record. The judgment always uses `OPENAI_API_KEY` and `gpt-6-luna`:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/04-structured-output/13-tashkent-fly-floor/fly_handover_test.rb
```

**Model**

The handover is `gpt-4.1-mini` on the Responses API. The deck call is `gpt-6-luna` on Decisions.
