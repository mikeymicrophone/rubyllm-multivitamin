# Error handling · 07 · Partridge Bank logbook

The chart desk pastes a season of Partridge Bank soundings — seven
hundred casts of tallow, sand, shell, and gravel — into one
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
| [`logbook_overflow.rb`](logbook_overflow.rb) | Embeds the season log |
| [`logbook_overflow_test.rb`](logbook_overflow_test.rb) | Replays the 400 and checks the class |
| [`cassettes/logbook_overflow.yml`](cassettes/logbook_overflow.yml) | The refused embeddings call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/07-partridge-bank-logbook/logbook_overflow.rb
bundle exec ruby features/13-error-handling/07-partridge-bank-logbook/logbook_overflow_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/13-error-handling/07-partridge-bank-logbook/logbook_overflow.rb
```

**Model**

`text-embedding-3-small` on OpenAI. Checked 15 October 2026.
