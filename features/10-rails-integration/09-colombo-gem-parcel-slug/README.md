# Rails integration · 09 · Colombo gem-parcel slug

The gem clerk on Sea Street opens a log on the free OpenRouter
slug with `assume_model_exists: true`, then switches to
`gpt-4.1-mini` for the 9-stone parcel question.

**What it teaches**

- `assume_model_exists` on `Chat.create!` saves a `ruby_llm_models` row for a slug missing from the bundled registry.
- `chat.model` is `RubyLLM::ActiveRecord::Model`. There is no application `acts_as_model` macro.
- `with_model` updates the persisted association before the ask.

**Files**

| File | Role |
| --- | --- |
| [`parcel_slug.rb`](parcel_slug.rb) | Creates the assumed slug, switches model, and asks the parcel |
| [`parcel_slug_test.rb`](parcel_slug_test.rb) | Replays the cassette and checks both model rows |
| [`cassettes/parcel_slug.yml`](cassettes/parcel_slug.yml) | The Chat Completions round-trip on gpt-4.1-mini |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/10-rails-integration/09-colombo-gem-parcel-slug/parcel_slug.rb
bundle exec ruby features/10-rails-integration/09-colombo-gem-parcel-slug/parcel_slug_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

The cassette is a live recording of `gpt-4.1-mini` on OpenAI after a live
OpenRouter `:free` probe returned empty content. Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/10-rails-integration/09-colombo-gem-parcel-slug/parcel_slug.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and
any `sk-` token before the file is written.

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). `LIVE_PROVIDER=openrouter`
records `nvidia/nemotron-3-super-120b-a12b:free` when the daily cap
allows. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
