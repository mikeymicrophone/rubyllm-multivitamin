# Tool approval and loop control · 01 · Port Ludlow publish latch

The dockmaster at Port Ludlow Marina will not let a model post the evening
fog notice until the latch is thrown. `publish_watch_notice` is declared
with `requires_approval`. `ask` parks. `approve` then `complete` posts
that the tender Marrowstone holds at the inner float after 21:00.

**What it teaches**

- `requires_approval` on a `RubyLLM::Tool` parks `ask`. `execute` has not
  run. `awaiting_approval?` and `waiting?` are true.
- `pending_approvals` lists the waiting `ToolCall`. `approve` then
  `complete` runs the tool and lets the model speak.
- The first request forces `publish_watch_notice`. `run_tools` clears
  that choice even though the call is still waiting, so the follow-up
  POST omits `tool_choice`.
- The time `21:00` is not in the first request. It arrives in the tool
  result.

**Files**

| File | Role |
| --- | --- |
| [`publish_latch.rb`](publish_latch.rb) | Parks the notice, then throws the latch |
| [`publish_latch_test.rb`](publish_latch_test.rb) | Replays the cassette |
| [`cassettes/publish_latch.yml`](cassettes/publish_latch.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/01-port-ludlow-publish-latch/publish_latch_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/01-port-ludlow-publish-latch/publish_latch_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
