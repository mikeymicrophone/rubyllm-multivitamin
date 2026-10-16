# Files · 03 · Bridgetown flying fish

The fry clerk in Bridgetown stores the morning flying-fish card for one
day. `expires_in: 86_400` sets `expires_at`. Gemini always expires at 48
hours; this catalog records OpenAI.

**What it teaches**

- `expires_in:` is seconds.
- `expires_at` is a Time.
- OpenAI accepts one hour to thirty days.

**Files**

| File | Role |
| --- | --- |
| [`flying_fish.rb`](flying_fish.rb) | Uploads the card with a one-day expiry |
| [`flying_fish_test.rb`](flying_fish_test.rb) | Checks `expires_at` |
| [`fish-card.pdf`](fish-card.pdf) | The fry card |
| [`cassettes/flying_fish.yml`](cassettes/flying_fish.yml) | The Files POST |

**Try it**

```sh
bundle exec ruby features/26-files/03-bridgetown-flying-fish/flying_fish.rb
bundle exec ruby features/26-files/03-bridgetown-flying-fish/flying_fish_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
