# Tools · 04 · Porto lodge cask book

The lodge clerk at Taylor's in Vila Nova de Gaia hands today's open book
to a tool instance. Cask 3 is touriga-nacional at 82 percent humidity,
lot PRT-1014-C3. The lot code is not in the question.

**What it teaches**

- `case/in` destructures a complete cask card and distinguishes missing cards from incomplete ones.
- Pass an instance to `with_tools` when the tool closes over today's book.
- `parameter :cask, type: :integer` declares an integer the model must send.
- `choice: LodgeCaskCard` still matches the instance, because the choice is
  the class.

**Files**

| File | Role |
| --- | --- |
| [`cask_card.rb`](cask_card.rb) | Closes over today's lodge book and asks for cask 3 |
| [`cask_card_test.rb`](cask_card_test.rb) | Checks the instance locally and replays the cassette |
| [`cassettes/cask_card.yml`](cassettes/cask_card.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/04-porto-lodge-cask/cask_card_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/04-porto-lodge-cask/cask_card_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
