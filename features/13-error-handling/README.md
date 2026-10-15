# Error handling

Provider failures inherit from `RubyLLM::Error`: `BadRequestError` (400), `UnauthorizedError` (401), `PaymentRequiredError` (402), `ForbiddenError` (403), `ContextLengthExceededError`, `ContentFilterError`, `ToolCallParseError`, `UnsupportedAttachmentError`, `UnsupportedServerToolError`, `RateLimitError` (429), `ServerError` (500), `ServiceUnavailableError` (502/503/504), and `OverloadedError` (529). `Error#response` is the Faraday response. `Error#request_shape` describes a rejected conversation without the prompt text.

Local failures inherit from `StandardError` directly: `ConfigurationError`, `PromptNotFoundError`, `ModelNotFoundError`, `InvalidRoleError`, `InvalidToolChoiceError`, `PendingToolCallsError`, `ModelRegistryError`, and `CancelledError`.

`with_fallbacks` tries the next model after a transient failure (rate limit, server error, unavailable, overloaded, timeout, connection failure) unless `on:` narrows that list. `before_fallback` and `after_fallback` observe the `RubyLLM::Fallback`. Faraday retries the same request for those transient classes, honoring `Retry-After`, up to `max_retries`. `ContextLengthExceededError` is not retried. A tool returns `{ error: }` to the model, or raises to the application.

Official reference: [Error handling](https://rubyllm.com/error-handling/).

## Models

`ConfigurationError`, `ModelNotFoundError`, `UnsupportedAttachmentError`, and the Point No Point timeout need no provider cassette. HTTP errors are live recordings: a 401 on a rejected OpenRouter key, a 429 on a free OpenRouter slug, a 400 on a broken OpenAI schema, and a 400 context overflow on `text-embedding-3-small`. Tool errors, cancellation, fallbacks that reach a working model, and the Restoration Point desk use OpenAI `gpt-4.1-mini`. Free-model 429s come and go with the shared pool and the daily `free-models-per-day` cap (reset 8 PM ET). Fallback slug when the first free model is gone: `liquid/lfm-2.5-2.6b:free`. Primary catalog chat slug: `nvidia/nemotron-3-super-120b-a12b:free`. Checked 15 October 2026.

## Examples (13 of 13 bottled)

01. [Turn Point missing key](01-turn-point-missing-key/) — available
02. [Patos Island unknown model](02-patos-island-unknown-model/) — available
03. [Cattle Point rejected key](03-cattle-point-rejected-key/) — available
04. [Iceberg Point rate limit](04-iceberg-point-rate-limit/) — available
05. [Protection Island request shape](05-protection-island-request-shape/) — available
06. [Hein Bank model fallback](06-hein-bank-model-fallback/) — available
07. [Partridge Bank logbook](07-partridge-bank-logbook/) — available
08. [Slip Point unsupported tape](08-slip-point-unsupported-tape/) — available
09. [West Point gauge error](09-west-point-gauge-error/) — available
10. [Browns Point cancelled brief](10-browns-point-cancelled-brief/) — available
11. [Point No Point retries](11-point-no-point-retries/) — available
12. [Foulweather Bluff fallback hooks](12-foulweather-bluff-fallback-hooks/) — available
13. [Restoration Point error desk](13-restoration-point-error-desk/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Unset key, `ConfigurationError`, no HTTP cassette |
| 02 | `ModelNotFoundError` from `find`, not from a guessed id |
| 03 | Cassette status 401 becomes `UnauthorizedError`; the shape omits the ledger |
| 04 | Status 429 becomes `RateLimitError`; `max_retries` 0 so the cassette stays one call |
| 05 | `BadRequestError#request_shape` has roles and sizes, not the auklet counts |
| 06 | `with_fallbacks` skips a 400 until `on:` lists `BadRequestError` |
| 07 | `ContextLengthExceededError` on an embedding; `request_shape` is nil |
| 08 | `UnsupportedAttachmentError` before any request, so `request_shape` is nil |
| 09 | One tool returns `{ error: }` and the model continues; the other raises |
| 10 | `CancelledError` is not a `RubyLLM::Error` |
| 11 | Faraday retries a timeout twice; the class is not `RubyLLM::Error` |
| 12 | The callbacks see `fallback.from`, `fallback.to`, and `fallback.error` |
| 13 | Capstone: rescue, log `request_shape.to_h`, ask again without the schema |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
