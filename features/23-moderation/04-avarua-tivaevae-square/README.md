# Moderation · 04 · Avarua tivaevae square

The studio clerk in Avarua screens a tivaevae square photograph before it
goes on the afternoon board. `moderate(with:)` reads the image. The square
is clean.

**What it teaches**

- `RubyLLM.moderate(with: path)` screens an image without a caption.
- Choose a model that takes images. `omni-moderation-latest` does.
- Other attachment types raise in a later slot.

**Files**

| File | Role |
| --- | --- |
| [`tivaevae_square.rb`](tivaevae_square.rb) | Screens the studio square |
| [`tivaevae_square_test.rb`](tivaevae_square_test.rb) | Checks the clean flag |
| [`tivaevae-square.png`](tivaevae-square.png) | The square on the board |
| [`cassettes/tivaevae_square.yml`](cassettes/tivaevae_square.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/04-avarua-tivaevae-square/tivaevae_square.rb
bundle exec ruby features/23-moderation/04-avarua-tivaevae-square/tivaevae_square_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/04-avarua-tivaevae-square/tivaevae_square.rb
```

**Model**

`omni-moderation-latest` on OpenAI. Checked 16 October 2026.
