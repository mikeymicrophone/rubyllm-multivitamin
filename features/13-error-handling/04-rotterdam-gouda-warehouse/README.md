# Error handling · 04 · Rotterdam gouda warehouse

The ripening clerk at a Rotterdam gouda warehouse reads a free OpenRouter
model for the humidity card. The shared free pool answers HTTP 429.
Faraday does not retry: `max_retries` is 0, so the cassette is one POST.

**What it teaches**

- Status 429 becomes `RubyLLM::RateLimitError`.
- `max_retries` 0 keeps the cassette to one call. Faraday would otherwise
  repeat a 429 whose `Retry-After` fits `retry_max_interval`.
- OpenRouter's daily cap message is `Rate limit exceeded:
  free-models-per-day`. That is still `RateLimitError`.
- `Error#response` holds the status and the body.

**Files**

| File | Role |
| --- | --- |
| [`rate_limit.rb`](rate_limit.rb) | Asks the humidity card on a free slug |
| [`rate_limit_test.rb`](rate_limit_test.rb) | Replays the 429 and checks the single interaction |
| [`cassettes/rate_limit.yml`](cassettes/rate_limit.yml) | The refused Chat Completions call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/13-error-handling/04-rotterdam-gouda-warehouse/rate_limit.rb
bundle exec ruby features/13-error-handling/04-rotterdam-gouda-warehouse/rate_limit_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/13-error-handling/04-rotterdam-gouda-warehouse/rate_limit.rb
```

Free slugs 429 when the shared pool or the daily cap is exhausted. If
the live call is 200, wait for the cap or try another `:free` slug.

**Model**

`poolside/laguna-s-2.1:free` on OpenRouter. Fallback slug if that one is
gone: `nvidia/nemotron-3-super-120b-a12b:free`. Checked 16 October 2026.
