# Tokenization · 13 · Machu Picchu terrace desk

The Machu Picchu terrace desk counts Quispe's and Huamán's dispatches against a growing
conversation. It reserves 100 of its application's 400-token allowance for output. In
the hand-authored fixture, Sisa's larger backlog crosses the 300-token input ceiling, so
the loop stops before staging or generating that turn. This is an application allowance,
not the model's context-window size.

**What it teaches**

- An explicit admission loop counts each candidate against the growing conversation.
- A separate output reserve defines the input ceiling; estimates never predict output
  length.
- Pattern matching destructures dispatch cards; break prevents staging an over-budget
  turn.

**Files**

| File | Role |
| --- | --- |
| [`terrace_desk.rb`](terrace_desk.rb) | Runs the desk |
| [`terrace_desk_test.rb`](terrace_desk_test.rb) | Checks the lesson and request shape |
| [`cassettes/terrace_desk.yml`](cassettes/terrace_desk.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/13-machu-picchu-terrace-desk/terrace_desk.rb
bundle exec ruby features/31-tokenization/13-machu-picchu-terrace-desk/terrace_desk_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 OPENAI_API_KEY=... bundle exec ruby
features/31-tokenization/13-machu-picchu-terrace-desk/terrace_desk.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

OpenAI `gpt-4.1-mini`. API shapes checked against the installed RubyLLM 2.1.1 source;
provider availability was not checked live.
