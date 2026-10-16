# Moderation · 11 · Recife frevo atelier

A review job at a Recife frevo loft screens a stored studio photograph
and writes `needs_review`. The square is clean, so the flag clears.
Active Storage is not in this catalog; the job passes the file path on
the row.

**What it teaches**

- A Rails-style job loads the record, screens the file, and writes the
  decision.
- `moderate(with:)` takes the path off the row.
- A clean square leaves `needs_review` false.

**Files**

| File | Role |
| --- | --- |
| [`frevo_job.rb`](frevo_job.rb) | Boots SQLite, creates the photo, runs the job |
| [`frevo_job_test.rb`](frevo_job_test.rb) | Checks the flag on the row |
| [`frevo-studio.png`](frevo-studio.png) | The studio square |
| [`cassettes/frevo_job.yml`](cassettes/frevo_job.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/11-recife-frevo-atelier/frevo_job.rb
bundle exec ruby features/23-moderation/11-recife-frevo-atelier/frevo_job_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/11-recife-frevo-atelier/frevo_job.rb
```

**Model**

`omni-moderation-latest` on OpenAI. Checked 16 October 2026.
