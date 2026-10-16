# Files · 06 · Mérida hammock loom

The loom clerk in Mérida turns automatic uploads off and asks about a
sisal hammock card. The card stays inline. Itzel starts lot MER-2026-1016-H7
at 09:20.

**What it teaches**

- `auto_upload_large_files = false` keeps attachments inline.
- A small card never hits `/files` either way. The flag is for the 50 MiB
  threshold.
- The cassette is one Responses POST.

**Files**

| File | Role |
| --- | --- |
| [`hammock_loom.rb`](hammock_loom.rb) | Asks with uploads off |
| [`hammock_loom_test.rb`](hammock_loom_test.rb) | Checks the flag and the brief |
| [`hammock-card.pdf`](hammock-card.pdf) | The loom card |
| [`cassettes/hammock_loom.yml`](cassettes/hammock_loom.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/26-files/06-merida-hammock-loom/hammock_loom.rb
bundle exec ruby features/26-files/06-merida-hammock-loom/hammock_loom_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
