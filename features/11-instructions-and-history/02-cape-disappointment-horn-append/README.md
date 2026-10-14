# Instructions and history · 02 · Cape Disappointment horn rule appended

The horn tender at Cape Disappointment Light posts the blast-card orders,
then appends a one-mile visibility rule before asking whether the horn
must run when the card says fair and the lookout has 0.6 mile.

**What it teaches**

- `with_instructions` replaces the system prompt by default.
- `append: true` adds a second `:system` message. `chat.messages` then
  starts with two system turns.
- Both texts go on the next request. On OpenAI Responses they are joined
  into one `instructions` string.

**Files**

| File | Role |
| --- | --- |
| [`horn_append.rb`](horn_append.rb) | Posts the card, appends the rule, and asks |
| [`horn_append_test.rb`](horn_append_test.rb) | Replays the cassette and checks both system texts |
| [`cassettes/horn_append.yml`](cassettes/horn_append.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/02-cape-disappointment-horn-append/horn_append.rb
bundle exec ruby features/11-instructions-and-history/02-cape-disappointment-horn-append/horn_append_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/02-cape-disappointment-horn-append/horn_append.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
