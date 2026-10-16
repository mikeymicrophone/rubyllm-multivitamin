# Instructions and history · 13 · Macau fuse-house shift reset

The overnight clerk at a Coloane firework workshop briefs a running fuse
house off the night board, then the morning relief assigns
`chat.messages = []`, posts new standing orders, and asks when packer
Mei-Ling can leave the packing bench.

**What it teaches**

- Assigning `chat.messages = []` resets the conversation on the same
  chat object.
- A new `with_instructions` after the reset is the only system prompt.
- The next `ask` does not see the overnight board. The morning request
  has 10:46 and does not have 07:05.

**Files**

| File | Role |
| --- | --- |
| [`shift_reset.rb`](shift_reset.rb) | Overnight brief, reset, morning ask |
| [`shift_reset_test.rb`](shift_reset_test.rb) | Replays the cassette and checks the fresh shift |
| [`cassettes/shift_reset.yml`](cassettes/shift_reset.yml) | Live recording of both asks |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/13-macau-fuse-reset/shift_reset.rb
bundle exec ruby features/11-instructions-and-history/13-macau-fuse-reset/shift_reset_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/13-macau-fuse-reset/shift_reset.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
