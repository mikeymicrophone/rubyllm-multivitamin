# Error handling · 06 · Papeete ukulele shop

The bench clerk at a Papeete ukulele shop first aims at a slug OpenRouter
has never listed. `with_fallbacks` to `gpt-4.1-mini` does not fire:
`BadRequestError` is not in `Fallback::DEFAULT_ERRORS`. Naming that class
in `on:` lets the same 400 fall through to OpenAI, which answers the
eight-billet board.

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
| [`ukulele_fallback.rb`](ukulele_fallback.rb) | Asks twice: default fallbacks, then `on:` |
| [`ukulele_fallback_test.rb`](ukulele_fallback_test.rb) | Replays the 400, 400, 200 cassette |
| [`cassettes/ukulele_fallback.yml`](cassettes/ukulele_fallback.yml) | Two OpenRouter refusals and one OpenAI brief |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/06-papeete-ukulele-shop/ukulele_fallback.rb
bundle exec ruby features/13-error-handling/06-papeete-ukulele-shop/ukulele_fallback_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/06-papeete-ukulele-shop/ukulele_fallback.rb
```

**Model**

Unlisted OpenRouter slug `papeete-ukulele-unlisted` with
`assume_model_exists: true`, then `gpt-4.1-mini` on OpenAI. Checked
16 October 2026.
