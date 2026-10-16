# Rails integration · 11 · Lucknow chikan tickets

The chikankari atelier in Chowk keeps a clerk-facing stitch ticket and
a separate `llm_messages` transcript. RubyLLM only sees the latter.

**What it teaches**

- `acts_as_chat messages: :llm_messages` points the model at a different association.
- The stitch ticket can hold a shorter clerk note. `llm_messages` keeps the system, user, and assistant rows.
- The two associations do not have to stay in lockstep.

**Files**

| File | Role |
| --- | --- |
| [`stitch_tickets.rb`](stitch_tickets.rb) | Asks on llm_messages and posts one stitch ticket |
| [`stitch_tickets_test.rb`](stitch_tickets_test.rb) | Replays the cassette and checks both associations |
| [`cassettes/stitch_tickets.yml`](cassettes/stitch_tickets.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/11-lucknow-chikan-tickets/stitch_tickets.rb
bundle exec ruby features/10-rails-integration/11-lucknow-chikan-tickets/stitch_tickets_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/11-lucknow-chikan-tickets/stitch_tickets.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
