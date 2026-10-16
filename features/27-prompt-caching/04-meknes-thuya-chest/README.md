# Prompt caching · 04 · Meknes thuya chest

The chest clerk in Meknes turns caching off. Fatima oils at 09:20.
`with_caching(nil)` raises. `with_caching(false)` sends no
`prompt_cache_options`.

**What it teaches**

- `with_caching(false)` is the off switch.
- `nil` is not off; it is `ArgumentError`.
- The request body has no ttl and no cache key.

**Files**

| File | Role |
| --- | --- |
| [`thuya_chest.rb`](thuya_chest.rb) | Tries nil, then false, then asks |
| [`thuya_chest_test.rb`](thuya_chest_test.rb) | Checks Fatima and the missing options |
| [`cassettes/thuya_chest.yml`](cassettes/thuya_chest.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/04-meknes-thuya-chest/thuya_chest.rb
bundle exec ruby features/27-prompt-caching/04-meknes-thuya-chest/thuya_chest_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
