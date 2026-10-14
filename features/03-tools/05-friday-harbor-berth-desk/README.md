# Tools · 05 · Friday Harbor berth desk

The berth clerk at Friday Harbor has two tools. One reads the water under
the float. One reads the clear fender of a numbered berth. The seiner
Kulshan is 48 ft, and the question is whether berth 7 has room. The model
has to pick the length tool.

**What it teaches**

- `with_tools` adds. Calling it again with `BerthLength` leaves
  `FloatDepth` registered.
- `with_tool_options(choice: :required)` sends `"tool_choice":"required"`.
  The model must call a tool. It still chooses which one.
- The length `54 ft` is only in the berth tool. The depth `11.2` should
  not appear in a tool result for this question.

**Files**

| File | Role |
| --- | --- |
| [`berth_desk.rb`](berth_desk.rb) | Registers both tools and asks about berth 7 |
| [`berth_desk_test.rb`](berth_desk_test.rb) | Checks registration locally and replays the cassette |
| [`cassettes/berth_desk.yml`](cassettes/berth_desk.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/05-friday-harbor-berth-desk/berth_desk_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/05-friday-harbor-berth-desk/berth_desk_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
