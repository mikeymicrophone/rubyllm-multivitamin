# Rails integration · 02 · New Dungeness lens log

The lens keeper at New Dungeness files the cabinet card with
`add_message`, then asks which drawer holds the 24-inch bullseye.
Reloading the log from SQLite keeps the same roles.

**What it teaches**

- `acts_as_message` persists roles, including the assistant.
- `add_message` appends the cabinet card without a provider call.
- A second `ask` adds another user row. Reloading the log keeps the drawer.

**Files**

| File | Role |
| --- | --- |
| [`lens_log.rb`](lens_log.rb) | Persists the cabinet card and asks for drawer 3 |
| [`lens_log_test.rb`](lens_log_test.rb) | Replays the cassette and checks roles after a reload |
| [`cassettes/lens_log.yml`](cassettes/lens_log.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/02-new-dungeness-lens-log/lens_log.rb
bundle exec ruby features/10-rails-integration/02-new-dungeness-lens-log/lens_log_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after the
free OpenRouter slugs hit the daily cap on 14 October 2026. Re-record
it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/02-new-dungeness-lens-log/lens_log.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Checked 14 October 2026.
