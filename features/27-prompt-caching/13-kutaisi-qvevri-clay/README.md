# Prompt caching · 13 · Kutaisi qvevri clay

The qvevri clerk in Kutaisi names the cache and asks twice. Nino seals
at 16:20. `ttl:`, `mode:`, and `cache_until_here` 400 on this slug;
those are earlier slots.

**What it teaches**

- Capstone: `key:` plus automatic caching and a follow-up.
- `cache_read` on the follow-up is an Integer. Zero is legal.
- Two Responses POSTs in one cassette.

**Files**

| File | Role |
| --- | --- |
| [`qvevri_clay.rb`](qvevri_clay.rb) | Names the cache, then asks twice |
| [`qvevri_clay_test.rb`](qvevri_clay_test.rb) | Checks Nino, No, and the key |
| [`cassettes/qvevri_clay.yml`](cassettes/qvevri_clay.yml) | Two Responses |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/13-kutaisi-qvevri-clay/qvevri_clay.rb
bundle exec ruby features/27-prompt-caching/13-kutaisi-qvevri-clay/qvevri_clay_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
