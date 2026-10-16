# Tokenization · 09 · Luang Prabang ferry ledger

Kham holds a ferry at the Ban Xieng Mene landing near Luang Prabang. The ledger counts
the staged request, completes it, and files the estimate beside the separately reported
input and output usage. The counting call does not fire the assistant-message callback.

**What it teaches**

- Count a staged request, then complete it and read billed response.tokens separately.
- after_message runs for generation, not the counting request.
- A lambda snapshots callbacks; zip/sum totals the separately named usage buckets.

**Files**

| File | Role |
| --- | --- |
| [`ferry_ledger.rb`](ferry_ledger.rb) | Runs the desk |
| [`ferry_ledger_test.rb`](ferry_ledger_test.rb) | Checks the lesson and request shape |
| [`cassettes/ferry_ledger.yml`](cassettes/ferry_ledger.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/09-luang-prabang-ferry-ledger/ferry_ledger.rb
bundle exec ruby features/31-tokenization/09-luang-prabang-ferry-ledger/ferry_ledger_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 OPENAI_API_KEY=... bundle exec ruby
features/31-tokenization/09-luang-prabang-ferry-ledger/ferry_ledger.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

OpenAI `gpt-4.1-mini`. API shapes checked against the installed RubyLLM 2.1.1 source;
provider availability was not checked live.
