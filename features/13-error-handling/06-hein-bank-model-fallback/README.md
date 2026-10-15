# Error handling · 06 · Hein Bank model fallback

The sounding desk over Hein Bank, the shoal south of San Juan Island,
first aims at a slug OpenRouter has never listed. `with_fallbacks` to
`gpt-4.1-mini` does not fire: `BadRequestError` is not in
`Fallback::DEFAULT_ERRORS`. Naming that class in `on:` lets the same
400 fall through to OpenAI, which answers the 8-fathom cast.

**What it teaches**

- `with_fallbacks` tries the next model after a matching error.
- The default list is rate limits, server errors, unavailable,
  overloaded, timeouts, and connection failures.
- `on:` replaces that list. A 400 needs `on: [RubyLLM::BadRequestError]`.
- Fallbacks can be a `RubyLLM::Model` from another provider.
- After the fallback answer, the chat returns to the original model.

**Files**

| File | Role |
| --- | --- |
| [`shoal_fallback.rb`](shoal_fallback.rb) | Asks twice: default fallbacks, then `on:` |
| [`shoal_fallback_test.rb`](shoal_fallback_test.rb) | Replays the 400, 400, 200 cassette |
| [`cassettes/shoal_fallback.yml`](cassettes/shoal_fallback.yml) | Two OpenRouter refusals and one OpenAI brief |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/06-hein-bank-model-fallback/shoal_fallback.rb
bundle exec ruby features/13-error-handling/06-hein-bank-model-fallback/shoal_fallback_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/06-hein-bank-model-fallback/shoal_fallback.rb
```

**Model**

Unlisted OpenRouter slug `hein-bank-shoal-unlisted` with
`assume_model_exists: true`, then `gpt-4.1-mini` on OpenAI. Checked
15 October 2026.
