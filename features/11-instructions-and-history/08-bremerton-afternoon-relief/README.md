# Instructions and history · 08 · Bremerton afternoon relief replaces orders

The morning gate clerk at the Port of Bremerton logs a shut gate and an
18.4 ft sill, then the afternoon relief replaces those standing orders
before writing the crew note.

**What it teaches**

- A second `with_instructions` replaces every system message.
- In RubyLLM 2.1.1 the replacement is appended at the end of
  `chat.messages`, so the roles just after the swap are
  `[:user, :assistant, :system]`.
- The encoder still lifts that system text into the next request. The
  morning orders are gone from the wire.

**Files**

| File | Role |
| --- | --- |
| [`afternoon_relief.rb`](afternoon_relief.rb) | Morning ask, replace orders, afternoon note |
| [`afternoon_relief_test.rb`](afternoon_relief_test.rb) | Replays the cassette and checks the swap |
| [`cassettes/afternoon_relief.yml`](cassettes/afternoon_relief.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/08-bremerton-afternoon-relief/afternoon_relief.rb
bundle exec ruby features/11-instructions-and-history/08-bremerton-afternoon-relief/afternoon_relief_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/08-bremerton-afternoon-relief/afternoon_relief.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
