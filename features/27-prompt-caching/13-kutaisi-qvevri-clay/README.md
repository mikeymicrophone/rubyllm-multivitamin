# Prompt caching · 13 · Kutaisi qvevri clay

The qvevri clerk in Kutaisi names the cache, sets a one-hour lifetime,
marks an explicit breakpoint, and asks twice. Nino seals at 16:20.

**What it teaches**

- Capstone: `ttl:`, `key:`, `mode: "explicit"`, and `cache_until_here`.
- `cache_read` on the follow-up is an Integer. Zero is legal.
- Two Responses POSTs in one cassette.

**Files**

| File | Role |
| --- | --- |
| [`qvevri_clay.rb`](qvevri_clay.rb) | Marks, names, then asks twice |
| [`qvevri_clay_test.rb`](qvevri_clay_test.rb) | Checks Nino, No, and the wire shape |
| [`cassettes/qvevri_clay.yml`](cassettes/qvevri_clay.yml) | Two Responses |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/13-kutaisi-qvevri-clay/qvevri_clay.rb
bundle exec ruby features/27-prompt-caching/13-kutaisi-qvevri-clay/qvevri_clay_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
