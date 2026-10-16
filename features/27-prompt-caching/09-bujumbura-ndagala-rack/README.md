# Prompt caching · 09 · Bujumbura ndagala rack

The rack clerk in Bujumbura marks the standing order with the keyword
form of `cache_until_here` and asks for implicit mode. Aline turns at
05:55.

**What it teaches**

- `with_instructions(..., cache_until_here: { ttl: "1h" })` is the same
  mark as the chained method.
- `with_caching(mode: "implicit")` still sends `prompt_cache_options`.
- Slot 03 used `mode: "explicit"` and `.cache_until_here`.

**Files**

| File | Role |
| --- | --- |
| [`ndagala_rack.rb`](ndagala_rack.rb) | Marks with the keyword, then asks |
| [`ndagala_rack_test.rb`](ndagala_rack_test.rb) | Checks implicit mode and Aline |
| [`cassettes/ndagala_rack.yml`](cassettes/ndagala_rack.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/09-bujumbura-ndagala-rack/ndagala_rack.rb
bundle exec ruby features/27-prompt-caching/09-bujumbura-ndagala-rack/ndagala_rack_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
