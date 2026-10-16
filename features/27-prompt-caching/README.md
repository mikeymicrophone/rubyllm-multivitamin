# Prompt caching

`chat.with_caching` turns on provider prompt caching. `cache_until_here` (and `with_instructions(..., cache_until_here:)`) marks a reusable prefix. Options: `ttl:`, `key:`, `mode:` (`"implicit"` / `"explicit"`), `id:` for a Gemini/Vertex cache. `RubyLLM.cache` creates a `RubyLLM::CachedContent` (`name`, `tokens`, `expires_at`, `renew`, `delete`, `find`). Read `response.tokens.cache_read` / `cache_write` and `cache_write_by_ttl`. Rails stores `cache_until_here` and `cache_ttl` on messages.

Official reference: [Prompt Caching](https://rubyllm.com/prompt-caching/).

## RubyLLM 2.1.1 entry points

- `chat.with_caching` / `with_caching(ttl: "1h")`
- `chat.cache_until_here` and `cache_until_here(ttl:)`
- `with_caching(false)`
- `RubyLLM.cache(...)` → `RubyLLM::CachedContent`
- `with_caching(id: cache)`
- `tokens.cache_read`, `tokens.cache_write`

## Providers that can record it

Anthropic, OpenRouter, Bedrock Converse, selected OpenAI-compatible models, Mistral (`key:`), Perplexity Router, Gemini and Vertex AI (explicit `RubyLLM.cache` resources). A cache hit is not guaranteed; providers set minimum prefix length. This catalog's cheap record path is OpenAI `gpt-4.1-mini` with empty `with_caching` and `with_caching(key:)`. That slug rejects `prompt_cache_options` (`ttl:`, `mode:`) and `prompt_cache_breakpoint`. `ttl: "1h"` 400s as an invalid value (only `30m` is listed) before the model-support check. Gemini `CachedContent` and Anthropic `cache_write_by_ttl` need keys this catalog does not have. Empty `with_caching` sends no `prompt_cache_options` unless `ttl:`, `key:`, or `mode:` is set. Checked 16 October 2026.

## Examples (13 of 13 bottled)

01. [Kairouan chechia felt](01-kairouan-chechia-felt/) — available
02. [Dubrovnik wall stone](02-dubrovnik-wall-stone/) — available
03. [Stavanger oil core](03-stavanger-oil-core/) — available
04. [Meknes thuya chest](04-meknes-thuya-chest/) — available
05. [Leh pashmina key](05-leh-pashmina-key/) — available
06. [Bukhara suzani cache](06-bukhara-suzani-cache/) — available
07. [Palembang songket](07-palembang-songket/) — available
08. [Cotonou zémidjan fare](08-cotonou-zemidjan-fare/) — available
09. [Puno totora reed](09-puno-totora-reed/) — available
10. [Basel Fasnacht lantern](10-basel-fasnacht-lantern/) — available
11. [Tampere Finlayson card](11-tampere-finlayson-card/) — available
12. [Wrocław Nadodrze neon](12-wroclaw-nadodrze-neon/) — available
13. [Kutaisi qvevri clay](13-kutaisi-qvevri-clay/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `with_caching` with no options; OpenAI sends no `prompt_cache_options` |
| 02 | `ttl: "1h"` vs `"30m"`: invalid value, then options unsupported |
| 03 | `cache_until_here` → `prompt_cache_breakpoint` 400 |
| 04 | `with_caching(false)`; `nil` is `ArgumentError` |
| 05 | `with_caching(key:)` → `prompt_cache_key` |
| 06 | `RubyLLM.cache` on OpenAI raises before HTTP |
| 07 | Second ask reports `tokens.cache_read` (zero is legal) |
| 08 | Rails stores `cache_until_here` / `cache_ttl`; false keeps it off the wire |
| 09 | `with_caching(mode: "implicit")` → options 400 |
| 10 | Too-short prefix; `cache_read` is 0 |
| 11 | Agent `caching` macro with no options |
| 12 | `cache_write_by_ttl` is nil on OpenAI |
| 13 | Capstone: named key, two asks |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
