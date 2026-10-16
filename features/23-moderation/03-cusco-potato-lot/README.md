# Moderation · 03 · Cusco potato lot

Three lot comments land on the Cusco potato desk. Two are clean. One
threatens the sorter. `moderate` takes the array. The outer `flagged?`
is true. The clerk still reads each verdict.

**What it teaches**

- `RubyLLM.moderate(["a", "b", "c"])` returns one `Result` per string.
- Outer `flagged?` is true if any comment is flagged.
- `flagged_categories` unions the families. Zip `results` with the array.

**Files**

| File | Role |
| --- | --- |
| [`potato_comments.rb`](potato_comments.rb) | Screens three lot comments |
| [`potato_comments_test.rb`](potato_comments_test.rb) | Checks the per-lot flags |
| [`cassettes/potato_comments.yml`](cassettes/potato_comments.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/03-cusco-potato-lot/potato_comments.rb
bundle exec ruby features/23-moderation/03-cusco-potato-lot/potato_comments_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/03-cusco-potato-lot/potato_comments.rb
```

**Model**

`omni-moderation-latest` on OpenAI. Checked 16 October 2026.
