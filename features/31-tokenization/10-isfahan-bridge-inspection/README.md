# Tokenization · 10 · Isfahan bridge inspection

Leila's Si-o-se-pol inspection question has a normal count and a second count after
hosted search, provider metadata, and a request hook are configured. The second counting
payload still excludes those additions, so the estimate cannot budget a future hosted
search.

**What it teaches**

- provider_tools, provider_options, and before_request hooks are omitted from
  count_tokens.
- A proc records hook execution while a pair of counts checks the same inspection
  question.
- The estimate covers the ordinary request, not a future hosted search.

**Files**

| File | Role |
| --- | --- |
| [`bridge_inspection.rb`](bridge_inspection.rb) | Runs the desk |
| [`bridge_inspection_test.rb`](bridge_inspection_test.rb) | Checks the lesson and request shape |
| [`cassettes/bridge_inspection.yml`](cassettes/bridge_inspection.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/10-isfahan-bridge-inspection/bridge_inspection.rb
bundle exec ruby features/31-tokenization/10-isfahan-bridge-inspection/bridge_inspection_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 OPENAI_API_KEY=... bundle exec ruby
features/31-tokenization/10-isfahan-bridge-inspection/bridge_inspection.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

OpenAI `gpt-4.1-mini`. API shapes checked against the installed RubyLLM 2.1.1 source;
provider availability was not checked live.
