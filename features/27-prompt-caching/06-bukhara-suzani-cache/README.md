# Prompt caching · 06 · Bukhara suzani cache

The suzani stall in Bukhara wants a provider-side cache of Dilshod's
standing order. `RubyLLM.cache` is Gemini and Vertex. OpenAI raises
before a socket opens. `cache.renew` is the same family.

**What it teaches**

- `RubyLLM.cache` is not `with_caching`.
- OpenAI raises `RubyLLM::Error` (`doesn't support explicit content
  caching`) with no HTTP call.
- This run does not write a cassette.

**Files**

| File | Role |
| --- | --- |
| [`suzani_cache.rb`](suzani_cache.rb) | Asks OpenAI to store a CachedContent |
| [`suzani_cache_test.rb`](suzani_cache_test.rb) | Checks the class and the missing cassette |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/06-bukhara-suzani-cache/suzani_cache.rb
bundle exec ruby features/27-prompt-caching/06-bukhara-suzani-cache/suzani_cache_test.rb
```

No API key is required. Checked 16 October 2026.
