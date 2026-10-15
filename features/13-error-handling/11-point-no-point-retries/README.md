# Error handling · 11 · Point No Point retries

The horn house at Point No Point, Hansville, calls a dead circuit for
the blast card. Faraday waits one second, retries twice, and then
raises `Faraday::TimeoutError`. The circuit accepted three connections
and never spoke. There is no provider cassette: the posts are to a
loopback socket the player ignores.

**What it teaches**

- The sleeper URL lives on a `RubyLLM.context`, not on
  `RubyLLM.config.openrouter_api_base`.
- `max_retries` 2 means one POST and two repeats for
  `Faraday::TimeoutError`.
- `ContextLengthExceededError` is not in Faraday's retry list.
- A timeout is not a `RubyLLM::Error`. Rescue it on its own.
- `retry_interval_randomness` 0 keeps the wait deterministic.

**Files**

| File | Role |
| --- | --- |
| [`horn_retries.rb`](horn_retries.rb) | Opens a sleeper socket and asks through it |
| [`horn_retries_test.rb`](horn_retries_test.rb) | Checks three accepts and the timeout class |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/11-point-no-point-retries/horn_retries.rb
bundle exec ruby features/13-error-handling/11-point-no-point-retries/horn_retries_test.rb
```

No API key is required. The sleeper is local. VCR ignores `127.0.0.1`.

**Model**

None. The request is aimed at the catalog chat slug, but the circuit
never answers.
