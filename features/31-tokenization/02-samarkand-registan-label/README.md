# Tokenization · 02 · Samarkand Registan label

Dilshod's Registan label repeats the word tile three times. The mosaic desk pairs token
IDs with xAI's raw token strings in order, keeping repeated IDs rather than sorting or
deduplicating them.

**What it teaches**

- xAI returns token_id entries; ids retain their text order, including repetitions.
- zip joins IDs to raw token strings; filter_map selects recurring mosaic words.
- A context owns its tokenizer credentials without changing global configuration.

**Files**

| File | Role |
| --- | --- |
| [`registan_label.rb`](registan_label.rb) | Runs the desk |
| [`registan_label_test.rb`](registan_label_test.rb) | Checks the lesson and request shape |
| [`cassettes/registan_label.yml`](cassettes/registan_label.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/02-samarkand-registan-label/registan_label.rb
bundle exec ruby features/31-tokenization/02-samarkand-registan-label/registan_label_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 XAI_API_KEY=... bundle exec ruby
features/31-tokenization/02-samarkand-registan-label/registan_label.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

xAI `grok-4.3`. API shapes checked against the installed RubyLLM 2.1.1 source; provider
availability was not checked live.
