# Prompt caching · 10 · Basel Fasnacht lantern

The lantern clerk in Basel keeps a short standing order and still turns
automatic caching on. Elsa hangs at 14:10. The prefix is under the
provider minimum, so `cache_read` is 0.

**What it teaches**

- A too-short prefix still enables automatic caching.
- Zero is a miss, not an error.
- Do not pad the board just to force a hit. `ttl:` is slot 02.

**Files**

| File | Role |
| --- | --- |
| [`fasnacht_lantern.rb`](fasnacht_lantern.rb) | Asks with a short prefix |
| [`fasnacht_lantern_test.rb`](fasnacht_lantern_test.rb) | Checks Elsa and a zero read |
| [`cassettes/fasnacht_lantern.yml`](cassettes/fasnacht_lantern.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/27-prompt-caching/10-basel-fasnacht-lantern/fasnacht_lantern.rb
bundle exec ruby features/27-prompt-caching/10-basel-fasnacht-lantern/fasnacht_lantern_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
