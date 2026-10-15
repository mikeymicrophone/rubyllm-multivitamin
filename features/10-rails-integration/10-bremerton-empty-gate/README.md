# Rails integration · 10 · Bremerton empty gate

The dry-dock clerk at Bremerton must allow an assistant row with
empty content. A presence validation on that column rejects the
streaming insert. The gate log leaves it off.

**What it teaches**

- An assistant row may have empty content. Streaming inserts that row before text arrives.
- `validates :content, presence: true` raises `ActiveRecord::RecordInvalid`.
- The scenario leaves the validation off so `ask` can persist.

**Files**

| File | Role |
| --- | --- |
| [`empty_gate.rb`](empty_gate.rb) | Saves a blank assistant row, shows the presence failure, then asks |
| [`empty_gate_test.rb`](empty_gate_test.rb) | Replays the cassette and checks the blank row and the validation |
| [`cassettes/empty_gate.yml`](cassettes/empty_gate.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/10-bremerton-empty-gate/empty_gate.rb
bundle exec ruby features/10-rails-integration/10-bremerton-empty-gate/empty_gate_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/10-bremerton-empty-gate/empty_gate.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
