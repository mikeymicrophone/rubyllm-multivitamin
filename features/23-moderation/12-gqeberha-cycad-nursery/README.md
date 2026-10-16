# Moderation · 12 · Gqeberha cycad nursery

The nursery clerk in Gqeberha screens a clean accession notice and logs
the raw assessments. `flagged?` is still the application API. `raw` keeps
OpenAI's `category_applied_input_types`.

**What it teaches**

- `result.raw` is the original provider body.
- OpenAI assessments live under `results[0]`.
- `flagged_categories` is still what the desk reads.

**Files**

| File | Role |
| --- | --- |
| [`cycad_raw.rb`](cycad_raw.rb) | Screens the notice and reads `raw` |
| [`cycad_raw_test.rb`](cycad_raw_test.rb) | Checks the raw id and assessments |
| [`cassettes/cycad_raw.yml`](cassettes/cycad_raw.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/12-gqeberha-cycad-nursery/cycad_raw.rb
bundle exec ruby features/23-moderation/12-gqeberha-cycad-nursery/cycad_raw_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/12-gqeberha-cycad-nursery/cycad_raw.rb
```

**Model**

`omni-moderation-latest` on OpenAI. Checked 16 October 2026.
