# Error handling · 12 · Noumea nickel matte

The converter desk at Doniambo, Noumea, first calls a dead circuit.
`max_retries` is 0 so Faraday does not triple the wait. `with_fallbacks`
then takes the 2.8-percent nickel card to `gpt-4.1-mini`.
`before_fallback` sees the timeout and the two model ids.
`after_fallback` sees `succeeded?`.

**What it teaches**

- `Faraday::TimeoutError` is in `Fallback::DEFAULT_ERRORS`.
- `request_timeout` is 2 so the dead circuit fails quickly. Replay
  hits the OpenAI cassette after that one wait.
- `before_fallback` receives a `RubyLLM::Fallback` with `from`, `to`,
  `error`, and `attempt`.
- `after_fallback` sees `succeeded?` and a nil `fallback_error` when
  the spare model answers.
- The loopback timeouts are not in the cassette. The OpenAI brief is.

**Files**

| File | Role |
| --- | --- |
| [`fallback_hooks.rb`](fallback_hooks.rb) | Times out on loopback, then asks OpenAI |
| [`fallback_hooks_test.rb`](fallback_hooks_test.rb) | Checks the hooks, the hits, and the brief |
| [`cassettes/fallback_hooks.yml`](cassettes/fallback_hooks.yml) | The OpenAI Responses call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/12-noumea-nickel-matte/fallback_hooks.rb
bundle exec ruby features/13-error-handling/12-noumea-nickel-matte/fallback_hooks_test.rb
```

Both commands replay the cassette. The sleeper is local. No API key is
required for replay.

Re-record the OpenAI brief with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/12-noumea-nickel-matte/fallback_hooks.rb
```

**Model**

Dead circuit aimed at `nvidia/nemotron-3-super-120b-a12b:free`, then
`gpt-4.1-mini` on OpenAI. Checked 16 October 2026.
