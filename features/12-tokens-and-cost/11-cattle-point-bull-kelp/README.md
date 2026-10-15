# Tokens and cost · 11 · Cattle Point bull-kelp harvest tools

The posted harvest card is not in the question. The kelp clerk at Cattle
Point reads bed CP-South through a tool, then files the sack count for
the skiff Haro. Token counts sit on the final answer and on the chat.

**What it teaches**

- A forced tool round still reports `tokens.input` and `tokens.output`
  on the spoken answer.
- `chat.tokens` includes the tool-call attempt, so chat input is at
  least the final answer's input.
- `cost.total` is still the provider's reported number (0 on this free
  slug).

**Files**

| File | Role |
| --- | --- |
| [`bull_kelp.rb`](bull_kelp.rb) | Forces the harvest-card tool, then reads usage |
| [`bull_kelp_test.rb`](bull_kelp_test.rb) | Replays the cassette and checks the counts |
| [`cassettes/bull_kelp.yml`](cassettes/bull_kelp.yml) | The tool call and the spoken answer |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/11-cattle-point-bull-kelp/bull_kelp.rb
bundle exec ruby features/12-tokens-and-cost/11-cattle-point-bull-kelp/bull_kelp_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/11-cattle-point-bull-kelp/bull_kelp.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter, with thinking off
so the tool call is not spent on reasoning. Fallback if that slug is
gone: `liquid/lfm-2.5-2.6b:free`, then OpenAI `gpt-4.1-mini` via
`LIVE_PROVIDER=openai`. Checked 15 October 2026.
