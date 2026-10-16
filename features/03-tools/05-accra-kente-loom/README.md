# Tools · 05 · Accra kente loom desk

The loom clerk at Bonwire, outside Accra, has two tools: reed sett and
remaining warp. Weaver Ama's festival strip is 48 cm. `choice: :required`
lets the model pick. It must call `cloth_length` for cloth 7, not the
decoy reed sett.

**What it teaches**

- `with_tools(ReedSett, ClothLength.new(cards: ...))` registers a class and an instance together. The instance holds the length cards.
- `parameters do` declares the cloth number using the Schematist DSL (the 2.1.1 form of older `params do` examples).
- `choice: :required` makes the model call a tool and leaves which tool
  to the model.
- The remaining warp `54 cm` is not in the question. The reed-sett tool
  would answer `11.2` and is a decoy.

**Files**

| File | Role |
| --- | --- |
| [`loom_desk.rb`](loom_desk.rb) | Registers both tools together and asks about cloth 7 |
| [`loom_desk_test.rb`](loom_desk_test.rb) | Checks the registered set and replays the cassette |
| [`cassettes/loom_desk.yml`](cassettes/loom_desk.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/05-accra-kente-loom/loom_desk_test.rb
```

The test replays the cassette. Its recorded request schemas were adjusted to the block DSL, which omits the redundant nested `strict` field; the recorded replies are unchanged. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/05-accra-kente-loom/loom_desk_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
