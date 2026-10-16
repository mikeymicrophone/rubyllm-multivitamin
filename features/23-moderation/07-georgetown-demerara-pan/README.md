# Moderation · 07 · Georgetown demerara pan

The pan clerk in Georgetown screens a boiling-pan photograph with its
caption. `moderate(caption, with:)` sends both. The pan is clean.

**What it teaches**

- Caption and image ride in one call.
- The request body holds the caption text and the image part.
- A clean mill card is not flagged.

**Files**

| File | Role |
| --- | --- |
| [`demerara_pan.rb`](demerara_pan.rb) | Screens the caption and the pan card |
| [`demerara_pan_test.rb`](demerara_pan_test.rb) | Checks the flag and the request body |
| [`pan-card.png`](pan-card.png) | The boiling-pan card |
| [`cassettes/demerara_pan.yml`](cassettes/demerara_pan.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/07-georgetown-demerara-pan/demerara_pan.rb
bundle exec ruby features/23-moderation/07-georgetown-demerara-pan/demerara_pan_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/07-georgetown-demerara-pan/demerara_pan.rb
```

**Model**

`omni-moderation-latest` on OpenAI. Checked 16 October 2026.
