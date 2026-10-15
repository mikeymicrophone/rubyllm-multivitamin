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

Anthropic, OpenRouter, Bedrock Converse, selected OpenAI-compatible models, Mistral (`key:`), Perplexity Router, Gemini and Vertex AI (explicit `RubyLLM.cache` resources). A cache hit is not guaranteed; providers set minimum prefix length. This catalog's cheap record path is OpenAI `gpt-4.1-mini` with `with_caching`, or Anthropic when a guaranteed breakpoint is the point. Free OpenRouter slugs may accept `ttl:` and still report zero cache tokens.

## Examples (0 of 13 bottled)

01. Union policy prefix — planned
02. Tahuya ttl 1h vs 5m — planned
03. Dewatto cache_until_here on instructions — planned
04. Seabeck with_caching(false) — planned
05. Bangor Gemini CachedContent — planned
06. Keyport cache.renew — planned
07. Poulsbo cache_read after second ask — planned
08. Liberty Bay Rails cache_ttl — planned
09. Bainbridge mode explicit — planned
10. Eagle Harbor too-short prefix — planned
11. Blakely Rock agent caching macro — planned
12. Alki write_by_ttl — planned
13. Duwamish cache desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
