# Files · 08 · Canberra mint blank

The press clerk at the Canberra mint stores a cupronickel blank card for
one hour. `expired?` is false while that window is open. Gemini's 48-hour
expiry is a different API.

**What it teaches**

- `expires_in: 3600` sets `expires_at`.
- `expired?` is true only when the window is gone or within one minute.
- This catalog records OpenAI, not Gemini.

**Files**

| File | Role |
| --- | --- |
| [`mint_blank.rb`](mint_blank.rb) | Uploads with a one-hour expiry |
| [`mint_blank_test.rb`](mint_blank_test.rb) | Checks `expired?` |
| [`mint-blank.pdf`](mint-blank.pdf) | The blank card |
| [`cassettes/mint_blank.yml`](cassettes/mint_blank.yml) | The Files POST |

**Try it**

```sh
bundle exec ruby features/26-files/08-canberra-mint-blank/mint_blank.rb
bundle exec ruby features/26-files/08-canberra-mint-blank/mint_blank_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
