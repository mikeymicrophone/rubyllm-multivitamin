# Prompt caching · 09 · Bujumbura ndagala rack

The rack clerk in Bujumbura asks for implicit cache mode. Aline's card
never leaves the desk as speech: `gpt-4.1-mini` answers HTTP 400,
`prompt_cache_options is not supported on this model`.

**What it teaches**

- `with_caching(mode: "implicit")` still sends `prompt_cache_options`.
- This cheap slug rejects the options object.
- Slot 03 used `cache_until_here`; this slot is the mode option.

**Files**

| File | Role |
| --- | --- |
| [`ndagala_rack.rb`](ndagala_rack.rb) | Sets implicit mode, then asks |
| [`ndagala_rack_test.rb`](ndagala_rack_test.rb) | Checks implicit mode and the 400 |
| [`cassettes/ndagala_rack.yml`](cassettes/ndagala_rack.yml) | One Responses 400 |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/09-bujumbura-ndagala-rack/ndagala_rack.rb
bundle exec ruby features/27-prompt-caching/09-bujumbura-ndagala-rack/ndagala_rack_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
