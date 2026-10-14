# Tools · 11 · Port Angeles net loft

The mending ticket at the Port Angeles net loft asks for No. 18 tarred
nylon and for the needle length. Both tools are registered. `choice:`
forces the twine tool. The spool count is 14, and that count is not in
the question.

**What it teaches**

- `with_tool_options(choice: TwineStock)` sends `"tool_choice":{"type":"function","name":"twine_stock"}`. The name is not nested under `function`. The needle tool stays in the `tools` array.
- After the forced call runs, RubyLLM clears the choice. The request that
  asks the model to answer has no `tool_choice`.
- The needle tool does not run, so its "6 inch" sentence is not a tool
  message.

**Files**

| File | Role |
| --- | --- |
| [`twine_stock.rb`](twine_stock.rb) | Registers both tools and forces the twine tool |
| [`twine_stock_test.rb`](twine_stock_test.rb) | Replays the cassette |
| [`cassettes/twine_stock.yml`](cassettes/twine_stock.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/11-port-angeles-net-loft/twine_stock_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/11-port-angeles-net-loft/twine_stock_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
