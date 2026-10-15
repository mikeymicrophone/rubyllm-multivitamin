# Tools · 03 · Olkaria wellhead card

The wellhead watch at Olkaria IV in Kenya reads 92 bar on well OW-914.
The posted minimum lives on the tool as an explicit numeric parameter
with a description. The question never names 85.

**What it teaches**

- `parameter` declares a type, a description, and `required: true`.
- A number stays a number in the schema (`pressure` is `"type":"number"`).
- The posted minimum is not in the question. The tool is what compares
  the gauge and names 85 bar in the result.

**Files**

| File | Role |
| --- | --- |
| [`wellhead_card.rb`](wellhead_card.rb) | Declares `pressure` and `station`, then asks whether the pad clears |
| [`wellhead_card_test.rb`](wellhead_card_test.rb) | Checks the schema locally and replays the cassette |
| [`cassettes/wellhead_card.yml`](cassettes/wellhead_card.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/03-olkaria-wellhead/wellhead_card_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/03-olkaria-wellhead/wellhead_card_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
