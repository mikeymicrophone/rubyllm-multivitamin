# Error handling · 11 · Gdansk amber lathe

The polish bench on Mariacka Street, Gdansk, calls a dead circuit for
the spindle card. Faraday waits one second, retries twice, and then
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
| [`amber_retries.rb`](amber_retries.rb) | Opens a sleeper socket and asks through it |
| [`amber_retries_test.rb`](amber_retries_test.rb) | Checks three accepts and the timeout class |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/11-gdansk-amber-lathe/amber_retries.rb
bundle exec ruby features/13-error-handling/11-gdansk-amber-lathe/amber_retries_test.rb
```

No API key is required. The sleeper is local. VCR ignores `127.0.0.1`.

**Model**

None. The request is aimed at the catalog chat slug, but the circuit
never answers.
