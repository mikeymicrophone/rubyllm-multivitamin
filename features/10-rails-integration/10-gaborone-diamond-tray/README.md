# Rails integration · 10 · Gaborone diamond-tray empty

The sort clerk in Gaborone must allow an assistant row with empty
content. A presence validation on that column rejects the streaming
insert. The tray log leaves it off.

**What it teaches**

- An assistant row may have empty content. Streaming inserts that row before text arrives.
- `validates :content, presence: true` raises `ActiveRecord::RecordInvalid`.
- The scenario leaves the validation off so `ask` can persist.

**Files**

| File | Role |
| --- | --- |
| [`empty_tray.rb`](empty_tray.rb) | Saves a blank assistant row, shows the presence failure, then asks |
| [`empty_tray_test.rb`](empty_tray_test.rb) | Replays the cassette and checks the blank row and the validation |
| [`cassettes/empty_tray.yml`](cassettes/empty_tray.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/10-gaborone-diamond-tray/empty_tray.rb
bundle exec ruby features/10-rails-integration/10-gaborone-diamond-tray/empty_tray_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/10-gaborone-diamond-tray/empty_tray.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
