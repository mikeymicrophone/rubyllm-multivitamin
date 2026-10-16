# Tokens and cost · 01 · Pokhara Sarangkot launch tokens

The launch clerk at Sarangkot, above Pokhara, asks when pilot Nabin can
clear the terrace wall. The clerk answers from the posted board, then
reads `tokens.input` and `tokens.output` off that message.

**What it teaches**

- `response.tokens` is a `RubyLLM::Tokens`.
- `tokens.input` and `tokens.output` are integers on a finished reply.
- `cost.total` is read off the same message. This free slug reports `0`.

**Files**

| File | Role |
| --- | --- |
| [`launch_tokens.rb`](launch_tokens.rb) | Asks the launch window and returns the token counts |
| [`launch_tokens_test.rb`](launch_tokens_test.rb) | Replays the cassette and checks the integers |
| [`cassettes/launch_tokens.yml`](cassettes/launch_tokens.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/01-pokhara-sarangkot-tokens/launch_tokens.rb
bundle exec ruby features/12-tokens-and-cost/01-pokhara-sarangkot-tokens/launch_tokens_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/01-pokhara-sarangkot-tokens/launch_tokens.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-or-v1-` token before the file is written.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
