# Instructions and history · 02 · Coimbra fado humidity rule appended

The hall keeper at a fado loft on Rua da Sofia posts the hall-card
orders, then appends a 40-percent humidity rule before asking whether
the hall must stay shut when the card says fair and the hygrometer
reads 36 percent.

**What it teaches**

- `with_instructions` replaces the system prompt by default.
- `append: true` adds a second `:system` message. `chat.messages` then
  starts with two system turns.
- Both texts go on the next request. On OpenAI Responses they are joined
  into one `instructions` string. On OpenRouter Chat Completions they
  are two `"role":"system"` messages.

**Files**

| File | Role |
| --- | --- |
| [`fado_append.rb`](fado_append.rb) | Posts the card, appends the rule, and asks |
| [`fado_append_test.rb`](fado_append_test.rb) | Replays the cassette and checks both system texts |
| [`cassettes/fado_append.yml`](cassettes/fado_append.yml) | Live recording of the appended-rule ask |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/02-coimbra-fado-append/fado_append.rb
bundle exec ruby features/11-instructions-and-history/02-coimbra-fado-append/fado_append_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/02-coimbra-fado-append/fado_append.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
