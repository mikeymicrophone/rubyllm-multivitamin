# Tools · 11 · Melbourne cricket-net stock

The practice ticket at the MCG net asks for four-piece Kookaburras and
the stump height. `choice: BallStock` forces the ball tool. After that
call runs, the next request omits `tool_choice`. The answer still names
the stumps, because the instructions say they were not read.

**What it teaches**

- `with_tool_options(choice:)` can force one tool while another stays
  registered.
- After that forced call runs, RubyLLM clears the choice so the model
  can answer without calling it again.
- On OpenAI's Responses API the forced name is flat:
  `"tool_choice":{"type":"function","name":"ball_stock"}`.

**Files**

| File | Role |
| --- | --- |
| [`ball_stock.rb`](ball_stock.rb) | Registers both tools and forces `ball_stock` |
| [`ball_stock_test.rb`](ball_stock_test.rb) | Checks the forced choice and replays the cassette |
| [`cassettes/ball_stock.yml`](cassettes/ball_stock.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/11-melbourne-cricket-net/ball_stock_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/11-melbourne-cricket-net/ball_stock_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
