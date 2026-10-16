# Tokenization · 12 · Lalibela manuscript refusal

Dawit tries two operations for the Lalibela manuscript desk: plain-text IDs on OpenAI
and a request count on OpenRouter. RubyLLM 2.1.1 rejects both locally. The desk keeps
the errors rather than inventing a count from character length.

**What it teaches**

- OpenAI has no plain-text tokenizer; OpenRouter Chat Completions has no counting
  endpoint.
- Rescue RubyLLM::Error per operation without substituting a character estimate.
- case/in classifies failures; no HTTP request or cassette is needed.

**Files**

| File | Role |
| --- | --- |
| [`manuscript_refusal.rb`](manuscript_refusal.rb) | Runs the desk |
| [`manuscript_refusal_test.rb`](manuscript_refusal_test.rb) | Checks the lesson and request shape |

**Try it**

```sh
bundle exec ruby features/31-tokenization/12-lalibela-manuscript-refusal/manuscript_refusal.rb
bundle exec ruby features/31-tokenization/12-lalibela-manuscript-refusal/manuscript_refusal_test.rb
```

No HTTP call is made, so there is no cassette. The test runs inside the shared cassette
player, which refuses unmatched requests. These unsupported-operation errors are local
library behavior, verified without a provider key.

**Model**

OpenAI `gpt-4.1-mini` and OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`. API
shapes checked against the installed RubyLLM 2.1.1 source; provider availability was not
checked live.
