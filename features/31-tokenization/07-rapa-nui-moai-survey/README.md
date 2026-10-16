# Tokenization · 07 · Rapa Nui moai survey

Hina's Ahu Tongariki conservation sheet identifies a moai under observation. The Rapa
Nui desk stages the PDF and its question with ask_later, counts the pending request, and
leaves generation for later.

**What it teaches**

- ask_later stages a new PDF before count_tokens; counting takes no with: keyword.
- An immutable field sheet carries its local path and the survey question.
- The count includes inline PDF bytes; the chat stays incomplete without generating.

**Files**

| File | Role |
| --- | --- |
| [`moai_survey.rb`](moai_survey.rb) | Runs the desk |
| [`moai_survey_test.rb`](moai_survey_test.rb) | Checks the lesson and request shape |
| [`cassettes/moai_survey.yml`](cassettes/moai_survey.yml) | Hand-authored HTTP fixture |
| [`fixtures/ahu-tongariki.pdf`](fixtures/ahu-tongariki.pdf) | Hand-authored, one-page conservation field sheet |

**Try it**

```sh
bundle exec ruby features/31-tokenization/07-rapa-nui-moai-survey/moai_survey.rb
bundle exec ruby features/31-tokenization/07-rapa-nui-moai-survey/moai_survey_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

The PDF is also hand-authored. Its actual bytes are encoded into the counting request;
no Files upload or generation is recorded.

Re-record with `LIVE=1 OPENAI_API_KEY=... bundle exec ruby
features/31-tokenization/07-rapa-nui-moai-survey/moai_survey.rb`. Leave `LIVE_PROVIDER`
unset; these scripts pin their provider and model. After recording, update this
provenance paragraph and validate any provider-dependent assertions.

**Model**

OpenAI `gpt-4.1-mini`. API shapes checked against the installed RubyLLM 2.1.1 source;
provider availability was not checked live.
