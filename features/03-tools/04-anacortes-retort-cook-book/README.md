# Tools · 04 · Anacortes retort cook book

The retort clerk at the Anacortes cannery has today's cook book open on
the bench. The tool is an instance that closes over that book. Basket 3
is sockeye, and the lot code is only in the book.

**What it teaches**

- `with_tools` accepts an instance. `initialize` keeps the cook book.
- `choice:` still accepts the class. RubyLLM finds the instance that
  `is_a?` that class.
- `parameter :basket, type: :integer` publishes `"type":"integer"`.
- The lot `ANC-1014-B3` is not in the question. The tool result carries
  it, and the answer repeats it.

**Files**

| File | Role |
| --- | --- |
| [`cook_card.rb`](cook_card.rb) | Builds the tool around today's book and asks about basket 3 |
| [`cook_card_test.rb`](cook_card_test.rb) | Checks the closed-over book locally and replays the cassette |
| [`cassettes/cook_card.yml`](cassettes/cook_card.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/04-anacortes-retort-cook-book/cook_card_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/04-anacortes-retort-cook-book/cook_card_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
