# Batches · 09 · Chisinau sunflower-press one-model rule

The press clerk in Chisinau tries to file one chat on `gpt-4.1-mini` and
one on `gpt-4o-mini`. OpenAI rejects the mix before upload.

**What it teaches**

- OpenAI batch requests must use one model per submission.
- Mixing `gpt-4.1-mini` and `gpt-4o-mini` raises before the upload.

**Files**

| File | Role |
| --- | --- |
| [`sunflower_press.rb`](sunflower_press.rb) | Stages two models and catches RubyLLM::Error |
| [`sunflower_press_test.rb`](sunflower_press_test.rb) | Checks the one-model message |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/09-chisinau-sunflower-press/sunflower_press.rb
bundle exec ruby features/21-batches/09-chisinau-sunflower-press/sunflower_press_test.rb
```

This slot makes no HTTP call. There is no cassette.

**Model**

No provider call. `single_batch_model!` raises in the OpenAI protocol.
