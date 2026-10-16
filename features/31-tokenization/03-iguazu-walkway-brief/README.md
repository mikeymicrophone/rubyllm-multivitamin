# Tokenization · 03 · Iguazú walkway brief

Marta and Diego post separate Iguazú walkway notices. A formatter builds one dispatch
bulletin, then counts the complete question without asking an assistant to answer it.

**What it teaches**

- RubyLLM.count_tokens counts a complete text request on OpenAI Responses.
- method(:format_notice) passed with & builds a bulletin from named closure rows.
- The returned Integer is an input estimate; no assistant turn is generated.

**Files**

| File | Role |
| --- | --- |
| [`walkway_brief.rb`](walkway_brief.rb) | Runs the desk |
| [`walkway_brief_test.rb`](walkway_brief_test.rb) | Checks the lesson and request shape |
| [`cassettes/walkway_brief.yml`](cassettes/walkway_brief.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/03-iguazu-walkway-brief/walkway_brief.rb
bundle exec ruby features/31-tokenization/03-iguazu-walkway-brief/walkway_brief_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 OPENAI_API_KEY=... bundle exec ruby
features/31-tokenization/03-iguazu-walkway-brief/walkway_brief.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

OpenAI `gpt-4.1-mini`. API shapes checked against the installed RubyLLM 2.1.1 source;
provider availability was not checked live.
