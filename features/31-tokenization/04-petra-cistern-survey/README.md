# Tokenization · 04 · Petra cistern survey

Nadia's Petra survey desk already has the Siq cistern measurement and an acknowledgement
in its transcript. The desk counts a follow-up against that history while leaving the
stored messages untouched.

**What it teaches**

- An instance owns a context chat with instructions and seeded survey history.
- chat.count_tokens(question) includes a temporary user turn without appending it.
- case/in destructures a survey record into a follow-up question.

**Files**

| File | Role |
| --- | --- |
| [`cistern_survey.rb`](cistern_survey.rb) | Runs the desk |
| [`cistern_survey_test.rb`](cistern_survey_test.rb) | Checks the lesson and request shape |
| [`cassettes/cistern_survey.yml`](cassettes/cistern_survey.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/04-petra-cistern-survey/cistern_survey.rb
bundle exec ruby features/31-tokenization/04-petra-cistern-survey/cistern_survey_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 OPENAI_API_KEY=... bundle exec ruby
features/31-tokenization/04-petra-cistern-survey/cistern_survey.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

OpenAI `gpt-4.1-mini`. API shapes checked against the installed RubyLLM 2.1.1 source;
provider availability was not checked live.
