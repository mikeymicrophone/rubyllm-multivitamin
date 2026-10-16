# Evaluations · 13 · Samarkand paper-vat desk capstone

The vat clerk at the Samarkand paper mill files vat SK-7: 27 sheets on the
line and sizing at 14:40 for Dilshod. Two Hash cases, a custom criterion,
progress names, and a saved JSON report.

**What it teaches**

- A desk eval can take Hash inputs, two cases, and a custom criterion.
- `run` yields progress names; `report.save` writes tokens beside the verdicts.
- Both cases must pass for `report.passed?`.

**Files**

| File | Role |
| --- | --- |
| [`paper_vat.rb`](paper_vat.rb) | Runs the two vat cases and writes the JSON report |
| [`paper_vat.yml`](paper_vat.yml) | Vat-count and sizing-window Hash cases |
| [`paper_vat_test.rb`](paper_vat_test.rb) | Replays the cassette and checks both criteria |
| [`cassettes/paper_vat.yml`](cassettes/paper_vat.yml) | Two clerk turns, four grader verdicts |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/13-samarkand-paper-vat/paper_vat.rb
bundle exec ruby features/20-evaluations/13-samarkand-paper-vat/paper_vat_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/13-samarkand-paper-vat/paper_vat.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
