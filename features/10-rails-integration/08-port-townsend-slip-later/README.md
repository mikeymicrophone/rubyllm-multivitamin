# Rails integration · 08 · Port Townsend slip later

The slip clerk at Port Townsend files the wind board with
`ask_later`, then a later `complete` — the split a job would use —
fills the assistant row.

**What it teaches**

- `ask_later` persists the user question without a provider call.
- `complete` runs the request later and fills the assistant row.
- The user count does not change when `complete` runs.

**Files**

| File | Role |
| --- | --- |
| [`slip_later.rb`](slip_later.rb) | Files the wind board, then completes the ask |
| [`slip_later_test.rb`](slip_later_test.rb) | Replays the cassette and checks the counts around complete |
| [`cassettes/slip_later.yml`](cassettes/slip_later.yml) | The Chat Completions round-trip from complete |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/08-port-townsend-slip-later/slip_later.rb
bundle exec ruby features/10-rails-integration/08-port-townsend-slip-later/slip_later_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/08-port-townsend-slip-later/slip_later.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
