# Moderation · 02 · Bulawayo township board

A threatening classifieds slip lands on the Makokoba township board in
Bulawayo. The clerk screens it before it is pinned. Omni-moderation flags
violence. The desk holds the slip.

**What it teaches**

- `flagged?` is true when the provider flags the comment.
- `flagged_categories` names the families. `category_scores` keeps the
  highest score per family.
- The mill still decides whether to pin. The model only reports.

**Files**

| File | Role |
| --- | --- |
| [`township_board.rb`](township_board.rb) | Screens the threatening slip |
| [`township_board_test.rb`](township_board_test.rb) | Checks the flag and the violence score |
| [`cassettes/township_board.yml`](cassettes/township_board.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/02-bulawayo-township-board/township_board.rb
bundle exec ruby features/23-moderation/02-bulawayo-township-board/township_board_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/02-bulawayo-township-board/township_board.rb
```

**Model**

`omni-moderation-latest` on OpenAI. Checked 16 October 2026.
