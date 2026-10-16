# Tokenization · 06 · Granada Alhambra plaster

Inés files an Alhambra plaster-loss slip for the Court of the Lions. The desk counts the
same question before and after installing a nested repair-card schema, keeping the
question out of the transcript both times.

**What it teaches**

- with_schema includes a nested Schematist schema in the token count.
- A fluent chat pipeline uses then to compare bare and structured request counts.
- Neither count stages a question or generates a JSON answer.

**Files**

| File | Role |
| --- | --- |
| [`plaster_card.rb`](plaster_card.rb) | Runs the desk |
| [`plaster_card_test.rb`](plaster_card_test.rb) | Checks the lesson and request shape |
| [`cassettes/plaster_card.yml`](cassettes/plaster_card.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/06-granada-alhambra-plaster/plaster_card.rb
bundle exec ruby features/31-tokenization/06-granada-alhambra-plaster/plaster_card_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 OPENAI_API_KEY=... bundle exec ruby
features/31-tokenization/06-granada-alhambra-plaster/plaster_card.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

OpenAI `gpt-4.1-mini`. API shapes checked against the installed RubyLLM 2.1.1 source;
provider availability was not checked live.
