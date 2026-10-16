# Prompt rendering · 07 · Yogyakarta wayang kulit

The dalang desk in Yogyakarta builds a `PuppetClerk` with no prompt
file and no `instructions` macro. Wayan cues figure YGY-2026-1016-W1
without a system turn.

**What it teaches**

- An Agent with no conventional prompt and no `instructions` macro
  starts without a system turn.
- The first message is the dalang's question.
- The missing file is not an error.

**Files**

| File | Role |
| --- | --- |
| [`wayang_kulit.rb`](wayang_kulit.rb) | Builds the clerk and asks |
| [`wayang_kulit_test.rb`](wayang_kulit_test.rb) | Checks the first role is `:user` |
| [`cassettes/wayang_kulit.yml`](cassettes/wayang_kulit.yml) | The ask |

**Try it**

```sh
bundle exec ruby features/28-prompt-rendering/07-yogyakarta-wayang-kulit/wayang_kulit.rb
bundle exec ruby features/28-prompt-rendering/07-yogyakarta-wayang-kulit/wayang_kulit_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Checked 16 October 2026.
