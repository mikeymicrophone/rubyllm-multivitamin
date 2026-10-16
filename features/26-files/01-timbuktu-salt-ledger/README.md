# Files · 01 · Timbuktu salt ledger

The salt clerk in Timbuktu uploads the morning ledger once, then asks
the chat with the stored file. Aisha weighs lot TMB-2026-1016-S3.

**What it teaches**

- `RubyLLM.upload` stores a PDF with `purpose: "user_data"`.
- `ask(..., with: file)` reuses the provider file id.
- The cassette is a Files POST then a Responses POST.

**Files**

| File | Role |
| --- | --- |
| [`salt_ledger.rb`](salt_ledger.rb) | Uploads the ledger and asks |
| [`salt_ledger_test.rb`](salt_ledger_test.rb) | Checks the file id and the brief |
| [`salt-ledger.pdf`](salt-ledger.pdf) | The morning ledger |
| [`cassettes/salt_ledger.yml`](cassettes/salt_ledger.yml) | Files then Responses |

**Try it**

```sh
bundle exec ruby features/26-files/01-timbuktu-salt-ledger/salt_ledger.rb
bundle exec ruby features/26-files/01-timbuktu-salt-ledger/salt_ledger_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI Files `purpose: "user_data"`, then `gpt-4.1-mini`. Checked 16 October 2026.
