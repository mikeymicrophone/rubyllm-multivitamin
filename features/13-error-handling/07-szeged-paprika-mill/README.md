# Error handling · 07 · Szeged paprika mill

The mill clerk pastes a season of Szeged paprika dryer readings — seven
hundred passes of kalocsa, csemege, erős, and nemes — into one
`text-embedding-3-small` call. The model will not take more than 8192
tokens. The overflow is `ContextLengthExceededError`, not a truncated
vector.

**What it teaches**

- A 400 whose message names a context length becomes
  `RubyLLM::ContextLengthExceededError`, not `BadRequestError`.
- Faraday does not retry that class. `max_retries` 0 keeps the cassette
  to one POST either way.
- `request_shape` is nil. Embeddings send no conversation.
- `Error#response` still has status 400 and the provider body.

**Files**

| File | Role |
| --- | --- |
| [`paprika_overflow.rb`](paprika_overflow.rb) | Embeds the season log |
| [`paprika_overflow_test.rb`](paprika_overflow_test.rb) | Replays the 400 and checks the class |
| [`cassettes/paprika_overflow.yml`](cassettes/paprika_overflow.yml) | The refused embeddings call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/07-szeged-paprika-mill/paprika_overflow.rb
bundle exec ruby features/13-error-handling/07-szeged-paprika-mill/paprika_overflow_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/07-szeged-paprika-mill/paprika_overflow.rb
```

**Model**

`text-embedding-3-small` on OpenAI. Checked 16 October 2026.
