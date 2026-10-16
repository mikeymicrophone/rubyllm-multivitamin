# Prompt caching · 05 · Leh pashmina key

The shawl clerk in Leh names the cache `leh-pashmina-2026-1016`. Tsering
weighs at 10:05. OpenAI takes `prompt_cache_key`. Gemini `CachedContent`
needs a key this catalog does not have.

**What it teaches**

- `with_caching(key:)` is the OpenAI named-cache path.
- `id:` is Gemini/Vertex. This mill does not send it.
- A named key is not a guaranteed hit.

**Files**

| File | Role |
| --- | --- |
| [`pashmina_key.rb`](pashmina_key.rb) | Names the cache, then asks |
| [`pashmina_key_test.rb`](pashmina_key_test.rb) | Checks the key and Tsering |
| [`cassettes/pashmina_key.yml`](cassettes/pashmina_key.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/05-leh-pashmina-key/pashmina_key.rb
bundle exec ruby features/27-prompt-caching/05-leh-pashmina-key/pashmina_key_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
