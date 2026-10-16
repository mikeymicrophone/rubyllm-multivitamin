# Prompt caching · 09 · Puno totora reed

The reed clerk in Puno asks for implicit cache mode. Yma's card never
leaves the desk as speech: `gpt-4.1-mini` answers HTTP 400,
`prompt_cache_options is not supported on this model`.

**What it teaches**

- `with_caching(mode: "implicit")` still sends `prompt_cache_options`.
- This cheap slug rejects the options object.
- Slot 03 used `cache_until_here`; this slot is the mode option.

**Files**

| File | Role |
| --- | --- |
| [`totora_reed.rb`](totora_reed.rb) | Sets implicit mode, then asks |
| [`totora_reed_test.rb`](totora_reed_test.rb) | Checks implicit mode and the 400 |
| [`cassettes/totora_reed.yml`](cassettes/totora_reed.yml) | One Responses 400 |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/09-puno-totora-reed/totora_reed.rb
bundle exec ruby features/27-prompt-caching/09-puno-totora-reed/totora_reed_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
