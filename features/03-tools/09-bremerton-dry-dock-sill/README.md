# Tools · 09 · Bremerton dry dock sill

The repair barge Kulshan is waiting on the tide. The first sentence of
the question names the barge. Bremerton shows up later. The sill card
for that station is 38 ft, and that depth is not in the question.

**What it teaches**

- The model has to pass `station:` from a later sentence, not from the
  opening line.
- The tool returns the sill card only when the station matches Bremerton.
- The depth `38` is on the tool message and in the answer.

**Files**

| File | Role |
| --- | --- |
| [`sill_depth.rb`](sill_depth.rb) | Asks for the sill and reads the Bremerton card |
| [`sill_depth_test.rb`](sill_depth_test.rb) | Checks the question locally and replays the cassette |
| [`cassettes/sill_depth.yml`](cassettes/sill_depth.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/09-bremerton-dry-dock-sill/sill_depth_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/09-bremerton-dry-dock-sill/sill_depth_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
