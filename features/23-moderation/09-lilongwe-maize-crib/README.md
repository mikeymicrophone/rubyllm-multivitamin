# Moderation · 09 · Lilongwe maize crib

The crib clerk in Lilongwe screens a clean fill-notice. Omni-moderation
returns scores for every family and flags none of them. Bedrock is the
provider that returns empty scores; this catalog records OpenAI.

**What it teaches**

- A clean hail still has `category_scores` keys.
- `flagged_categories` is empty. The scores are not.
- `raw` still holds the provider body.

**Files**

| File | Role |
| --- | --- |
| [`maize_scores.rb`](maize_scores.rb) | Screens the fill-notice |
| [`maize_scores_test.rb`](maize_scores_test.rb) | Checks the score keys |
| [`cassettes/maize_scores.yml`](cassettes/maize_scores.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/09-lilongwe-maize-crib/maize_scores.rb
bundle exec ruby features/23-moderation/09-lilongwe-maize-crib/maize_scores_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/09-lilongwe-maize-crib/maize_scores.rb
```

**Model**

`omni-moderation-latest` on OpenAI. Checked 16 October 2026.
