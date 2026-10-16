# Extended thinking · 03 · Hotan jade pebble

The jade desk in Hotan pins a 1024-token thinking budget. Gulnisa
grades pebble HOT-2026-1016-J2. OpenAI keeps the budget on
`chat.thinking` and leaves it off the Responses body. Nemotron sends
`reasoning.max_tokens`.

**What it teaches**

- `budget:` on `gpt-5-nano` is kept on `chat.thinking` but omitted from
  the Responses reasoning object.
- The same budget on Nemotron is `reasoning.max_tokens`.
- One cassette holds both asks.

**Files**

| File | Role |
| --- | --- |
| [`jade.rb`](jade.rb) | Asks OpenAI then OpenRouter with the same budget |
| [`jade_test.rb`](jade_test.rb) | Checks both wires |
| [`cassettes/jade.yml`](cassettes/jade.yml) | Both asks |

**Try it**

```sh
bundle exec ruby features/29-extended-thinking/03-hotan-jade-pebble/jade.rb
bundle exec ruby features/29-extended-thinking/03-hotan-jade-pebble/jade_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=... OPENROUTER_API_KEY=...`.

**Model**

OpenAI `gpt-5-nano`, then OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`.
Checked 16 October 2026.
