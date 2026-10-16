# Error handling · 01 · Oranjestad aloe vat

The packing clerk at an Oranjestad aloe vat, on Aruba's west coast, has
no OpenRouter key. Building a chat for the gel-cut brief raises
`RubyLLM::ConfigurationError` on the desk. Nothing is posted to a provider.

**What it teaches**

- Clearing `openrouter_api_key` makes OpenRouter unconfigured.
- `RubyLLM.chat` raises `ConfigurationError` before any HTTP call.
- `ConfigurationError` inherits `StandardError`, not `RubyLLM::Error`.
  A `rescue RubyLLM::Error` misses it.
- This run does not open a socket. There is no cassette file.

**Files**

| File | Role |
| --- | --- |
| [`missing_key.rb`](missing_key.rb) | Clears the key and rescues the two error classes |
| [`missing_key_test.rb`](missing_key_test.rb) | Checks the class, the superclass, and the message |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/01-oranjestad-aloe-vat/missing_key.rb
bundle exec ruby features/13-error-handling/01-oranjestad-aloe-vat/missing_key_test.rb
```

No API key is required.

**Model**

None. This run never calls a provider.
