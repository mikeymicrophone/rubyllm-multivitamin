# Tokens and cost · 11 · Freetown gara-cloth harvest tools

The posted dye card is not in the question. The gara clerk at the Cotton
Tree yard in Freetown reads bed CT-South through a tool, then files the
yardage for the cart Lumley. Token counts sit on the final answer and on
the chat.

**What it teaches**

- A forced tool round still reports `tokens.input` and `tokens.output`
  on the spoken answer.
- The first call invents a keyword the tool does not take. That becomes
  a tool-role JSON error, and the model calls again with `{}`.
  `chat.tokens` includes both attempts.
- `cost.total` is still the provider's reported number (0 on this free
  slug).

**Files**

| File | Role |
| --- | --- |
| [`gara_cloth.rb`](gara_cloth.rb) | Forces the dye-card tool, then reads usage |
| [`gara_cloth_test.rb`](gara_cloth_test.rb) | Replays the cassette and checks the counts |
| [`cassettes/gara_cloth.yml`](cassettes/gara_cloth.yml) | The tool call and the spoken answer |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/11-freetown-gara-cloth/gara_cloth.rb
bundle exec ruby features/12-tokens-and-cost/11-freetown-gara-cloth/gara_cloth_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/11-freetown-gara-cloth/gara_cloth.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter, with thinking off
so the tool call is not spent on reasoning. Fallback if that slug is
gone: `liquid/lfm-2.5-2.6b:free`, then OpenAI `gpt-4.1-mini` via
`LIVE_PROVIDER=openai`. Checked 16 October 2026.
