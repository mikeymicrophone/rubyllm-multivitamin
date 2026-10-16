# Tokens and cost · 04 · Manaus açaí lot versus hail

The lot clerk at the Manaus riverfront açaí shed posts lot AMZ-441 twice:
once from the full harvest log, once from a one-line hail. Two chats.
The longer prompt reports more input tokens.

**What it teaches**

- Two chats share instructions and differ only in the user prompt.
- The longer lot card reports more `tokens.input` than the hail.
- Output counts are still present. The comparison the test locks is input.

**Files**

| File | Role |
| --- | --- |
| [`acai_lot.rb`](acai_lot.rb) | Asks the lot card and the hail on separate chats |
| [`acai_lot_test.rb`](acai_lot_test.rb) | Replays the cassette and compares the input counts |
| [`cassettes/acai_lot.yml`](cassettes/acai_lot.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/04-manaus-acai-lot/acai_lot.rb
bundle exec ruby features/12-tokens-and-cost/04-manaus-acai-lot/acai_lot_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/04-manaus-acai-lot/acai_lot.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that
slug hits `free-models-per-day`: `LIVE_PROVIDER=openai` records
`gpt-4.1-mini`. Checked 16 October 2026.
