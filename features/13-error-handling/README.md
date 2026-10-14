# Error handling

Provider failures inherit from `RubyLLM::Error`: `BadRequestError` (400), `UnauthorizedError` (401), `PaymentRequiredError` (402), `ForbiddenError` (403), `ContextLengthExceededError`, `ContentFilterError`, `ToolCallParseError`, `UnsupportedAttachmentError`, `UnsupportedServerToolError`, `RateLimitError` (429), `ServerError` (500), `ServiceUnavailableError` (502/503/504), and `OverloadedError` (529). `Error#response` is the Faraday response. `Error#request_shape` describes a rejected conversation without the prompt text.

Local failures inherit from `StandardError` directly: `ConfigurationError`, `PromptNotFoundError`, `ModelNotFoundError`, `InvalidRoleError`, `InvalidToolChoiceError`, `PendingToolCallsError`, `ModelRegistryError`, and `CancelledError`.

`with_fallbacks` tries the next model after a transient failure (rate limit, server error, unavailable, overloaded, timeout, connection failure) unless `on:` narrows that list. `before_fallback` and `after_fallback` observe the `RubyLLM::Fallback`. Faraday retries the same request for those transient classes, honoring `Retry-After`, up to `max_retries`. `ContextLengthExceededError` is not retried. A tool returns `{ error: }` to the model, or raises to the application.

Official reference: [Error handling](https://rubyllm.com/error-handling/).

## Free models

`ConfigurationError` and `ModelNotFoundError` need no cassette. HTTP errors are cassettes: record a 401, a 429 with `Retry-After`, a 400, and a 503, or hand-author those status bodies in OpenRouter's error JSON. Fallback slug when the first free model is rate-limited: `liquid/lfm-2.5-2.6b:free`. Primary: `nvidia/nemotron-3-super-120b-a12b:free`. Free models are the ones most likely to answer 429. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. Missing OpenRouter key at the watch desk — planned
02. Unknown model id for the station — planned
03. A rejected key — planned
04. Rate limit on the free tide model — planned
05. A bad request and its request_shape — planned
06. Fall back from one free model to another — planned
07. Context length on a pasted logbook — planned
08. A file the foghorn model will not take — planned
09. A tool that returns an error versus a tool that raises — planned
10. Cancel the in-flight brief — planned
11. OpenRouter unavailable during the weather round — planned
12. before_fallback and after_fallback on the watch — planned
13. The desk rescues, logs the shape, and falls back — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Unset key, `ConfigurationError`, no HTTP cassette |
| 02 | `ModelNotFoundError` from `find`, not from a guessed id |
| 03 | Cassette status 401 becomes `UnauthorizedError` |
| 04 | Status 429 with `Retry-After` becomes `RateLimitError`; `max_retries` 0 so the cassette stays one call |
| 05 | `BadRequestError#request_shape` has roles and sizes, not the board text |
| 06 | `with_fallbacks` and a 503 then a 200; `on:` lists the classes |
| 07 | `ContextLengthExceededError` is not followed by a second identical POST |
| 08 | `UnsupportedAttachmentError` before any request, so `request_shape` is nil |
| 09 | One tool returns `{ error: }` and the model continues; the other raises |
| 10 | `CancelledError` is not a `RubyLLM::Error` |
| 11 | Status 503 becomes `ServiceUnavailableError` |
| 12 | The callbacks see `fallback.from`, `fallback.to`, and `fallback.error` |
| 13 | Capstone: rescue, log `request_shape.to_h`, fall back to the second free slug |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
