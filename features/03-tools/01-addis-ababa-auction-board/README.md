# Tools · 01 · Addis Ababa coffee-auction chalkboard

The floor clerk at the Ethiopia Commodity Exchange in Addis Ababa does
not have the morning chalkboard in the question. A tool with no
parameters reads the posted lots and returns them as a string. The
brief names when lot clerk Halima and cupper Tadesse can work the
sample table.

**What it teaches**

- A tool is a subclass of `RubyLLM::Tool` with `description` and `execute`.
- `self.tool_name` is the name on the wire. The default for a nested class
  keeps the module and writes `::` as `--`. This tool overrides it to
  `posted_lot_board`.
- `with_tools` registers the class. RubyLLM 2.1.1 has no `with_tool`.
- `execute` with no keywords publishes an empty object schema.
- A String return is stored as the `:tool` message content, not as JSON.
- `with_tool_options(choice:)` can pin that one tool.
- The times `10:46` and `08:57` are not in the question. They arrive in
  the tool result and the final answer repeats them.
- `with_thinking(false)` raises on `gpt-4.1-mini` before a request. The registry has no off control. The recorded request still includes `reasoning.encrypted_content` and does not send `"reasoning":{"enabled":false}`. `LIVE_PROVIDER=openrouter` still sends that toggle.

**Files**

| File | Role |
| --- | --- |
| [`auction_board.rb`](auction_board.rb) | Registers the chalkboard tool and asks for the window |
| [`auction_board_test.rb`](auction_board_test.rb) | Replays the cassette |
| [`cassettes/auction_board.yml`](cassettes/auction_board.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/01-addis-ababa-auction-board/auction_board_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/01-addis-ababa-auction-board/auction_board_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
