# Error handling

Provider failures inherit from `RubyLLM::Error`: `BadRequestError` (400), `UnauthorizedError` (401), `PaymentRequiredError` (402), `ForbiddenError` (403), `ContextLengthExceededError`, `ContentFilterError`, `ToolCallParseError`, `UnsupportedAttachmentError`, `UnsupportedServerToolError`, `RateLimitError` (429), `ServerError` (500), `ServiceUnavailableError` (502/503/504), and `OverloadedError` (529). `Error#response` is the Faraday response. `Error#request_shape` describes a rejected conversation without the prompt text.

Local failures inherit from `StandardError` directly: `ConfigurationError`, `PromptNotFoundError`, `ModelNotFoundError`, `InvalidRoleError`, `InvalidToolChoiceError`, `PendingToolCallsError`, `ModelRegistryError`, and `CancelledError`.

`with_fallbacks` tries the next model after a transient failure (rate limit, server error, unavailable, overloaded, timeout, connection failure) unless `on:` narrows that list. `before_fallback` and `after_fallback` observe the `RubyLLM::Fallback`. Faraday retries the same request for those transient classes, honoring `Retry-After`, up to `max_retries`. `ContextLengthExceededError` is not retried. A tool returns `{ error: }` to the model, or raises to the application.

Official reference: [Error handling](https://rubyllm.com/error-handling/).

## Models

`ConfigurationError`, `ModelNotFoundError`, `UnsupportedAttachmentError`, and the Gdansk amber-lathe timeout need no provider cassette. HTTP errors are live recordings: a 401 on a rejected OpenRouter key, a 429 on a free OpenRouter slug, a 400 on a broken OpenAI schema, and a 400 context overflow on `text-embedding-3-small`. Tool errors, cancellation, fallbacks that reach a working model, and the Willemstad peel desk use OpenAI `gpt-4.1-mini`. Free-model 429s come and go with the shared pool and the daily `free-models-per-day` cap (reset 8 PM ET). Fallback slug when the first free model is gone: `liquid/lfm-2.5-2.6b:free`. Primary catalog chat slug: `nvidia/nemotron-3-super-120b-a12b:free`. Checked 16 October 2026.

## Examples (13 of 13 bottled)

01. [Oranjestad aloe vat](01-oranjestad-aloe-vat/) — available
02. [Fukuoka yatai burner](02-fukuoka-yatai-burner/) — available
03. [Doha falcon mews](03-doha-falcon-mews/) — available
04. [Rotterdam gouda warehouse](04-rotterdam-gouda-warehouse/) — available
05. [Hue imperial lantern](05-hue-imperial-lantern/) — available
06. [Papeete ukulele shop](06-papeete-ukulele-shop/) — available
07. [Szeged paprika mill](07-szeged-paprika-mill/) — available
08. [Mechelen carillon](08-mechelen-carillon/) — available
09. [Salalah frankincense scale](09-salalah-frankincense-scale/) — available
10. [Napier art deco](10-napier-art-deco/) — available
11. [Gdansk amber lathe](11-gdansk-amber-lathe/) — available
12. [Noumea nickel matte](12-noumea-nickel-matte/) — available
13. [Willemstad curaçao peel](13-willemstad-curacao-peel/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Unset key, `ConfigurationError`, no HTTP cassette |
| 02 | `ModelNotFoundError` from `find`, not from a guessed id |
| 03 | Cassette status 401 becomes `UnauthorizedError`; the shape omits the ledger |
| 04 | Status 429 becomes `RateLimitError`; `max_retries` 0 so the cassette stays one call |
| 05 | `BadRequestError#request_shape` has roles and sizes, not the lantern counts |
| 06 | `with_fallbacks` skips a 400 until `on:` lists `BadRequestError` |
| 07 | `ContextLengthExceededError` on an embedding; `request_shape` is nil |
| 08 | `UnsupportedAttachmentError` before any request, so `request_shape` is nil |
| 09 | One tool returns `{ error: }` and the model continues; the other raises |
| 10 | `CancelledError` is not a `RubyLLM::Error` |
| 11 | Faraday retries a timeout twice; the class is not `RubyLLM::Error` |
| 12 | The callbacks see `fallback.from`, `fallback.to`, and `fallback.error` |
| 13 | Capstone: rescue, log `request_shape.to_h`, ask again without the schema |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
