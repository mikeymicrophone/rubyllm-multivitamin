# Tokenization · 08 · Valparaíso funicular dispatch

Camila and Tomás post notices for two Valparaíso funiculars. A scoped String refinement
cleans the notice lines. The dispatcher stages a chat but sends only its bulletin text
to xAI's tokenizer, leaving the standing instructions and message framing out of that
payload.

**What it teaches**

- Tokenize extracts only a staged bulletin's plain text, excluding the chat's
  instructions.
- A refinement cleans posted lines without changing String globally.
- lazy and numbered block parameters build the dispatch bulletin.

**Files**

| File | Role |
| --- | --- |
| [`funicular_dispatch.rb`](funicular_dispatch.rb) | Runs the desk |
| [`funicular_dispatch_test.rb`](funicular_dispatch_test.rb) | Checks the lesson and request shape |
| [`cassettes/funicular_dispatch.yml`](cassettes/funicular_dispatch.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/08-valparaiso-funicular-dispatch/funicular_dispatch.rb
bundle exec ruby features/31-tokenization/08-valparaiso-funicular-dispatch/funicular_dispatch_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 XAI_API_KEY=... bundle exec ruby
features/31-tokenization/08-valparaiso-funicular-dispatch/funicular_dispatch.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

xAI `grok-4.3`. API shapes checked against the installed RubyLLM 2.1.1 source; provider
availability was not checked live.
