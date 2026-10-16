# Tokenization · 01 · Kyoto torii inscription

Akiko checks a Fushimi Inari torii inscription before it goes on a compact label. The
desk tokenizes the Japanese and English text, retains the provider response, and checks
a 40-token label allowance.

**What it teaches**

- Cohere tokenize returns ids, count, model, and the unmodified raw response.
- A customized immutable Data record checks an inscription against a label allowance.
- Plain-text IDs exclude request formatting and billed usage.

**Files**

| File | Role |
| --- | --- |
| [`torii_inscription.rb`](torii_inscription.rb) | Runs the desk |
| [`torii_inscription_test.rb`](torii_inscription_test.rb) | Checks the lesson and request shape |
| [`cassettes/torii_inscription.yml`](cassettes/torii_inscription.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/01-kyoto-torii-inscription/torii_inscription.rb
bundle exec ruby features/31-tokenization/01-kyoto-torii-inscription/torii_inscription_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 COHERE_API_KEY=... bundle exec ruby
features/31-tokenization/01-kyoto-torii-inscription/torii_inscription.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

Cohere `command-r-08-2024`. API shapes checked against the installed RubyLLM 2.1.1
source; provider availability was not checked live.
