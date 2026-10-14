# Tools · 03 · Cape Disappointment compressor

The foghorn watch at Cape Disappointment reads 92 psi on the compressor
gauge. The posted minimum is not in the question. `parameter` tells the
model the gauge is a number and the station is a string, both required.

**What it teaches**

- `parameter` sets `type`, `description`, and `required: true`.
- `:number` is `"number"` in the schema. `:string` stays `"string"`.
- Both names are listed in `required`, in declaration order.
- The tool compares the gauge with 85 psi and returns a sentence. The
  answer has to include that minimum.
- The first request carries the schema and does not carry `85`.

**Files**

| File | Role |
| --- | --- |
| [`compressor_card.rb`](compressor_card.rb) | Declares the gauge parameters and asks the watch question |
| [`compressor_card_test.rb`](compressor_card_test.rb) | Checks the schema locally and replays the cassette |
| [`cassettes/compressor_card.yml`](cassettes/compressor_card.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/03-cape-disappointment-compressor/compressor_card_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/03-cape-disappointment-compressor/compressor_card_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
