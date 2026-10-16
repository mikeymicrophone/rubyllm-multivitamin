# Moderation · 01 · Tamale groundnut paste

The mill clerk in Tamale posts the morning groundnut-paste hail. Omni-moderation
lets it through. `flagged?` is false. The desk does not hold a clean card.

**What it teaches**

- `RubyLLM.moderate` screens a string on OpenAI `omni-moderation-latest`.
- `flagged?` is the provider's decision. The mill still decides what to post.
- A clean hail still has `category_scores` keys. The names are empty.

**Files**

| File | Role |
| --- | --- |
| [`groundnut_hail.rb`](groundnut_hail.rb) | Screens the mill hail |
| [`groundnut_hail_test.rb`](groundnut_hail_test.rb) | Replays the cassette and checks `flagged?` |
| [`cassettes/groundnut_hail.yml`](cassettes/groundnut_hail.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/01-tamale-groundnut-paste/groundnut_hail.rb
bundle exec ruby features/23-moderation/01-tamale-groundnut-paste/groundnut_hail_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/01-tamale-groundnut-paste/groundnut_hail.rb
```

**Model**

`omni-moderation-latest` on OpenAI. OpenRouter has no separate moderation
operation. Checked 16 October 2026.
