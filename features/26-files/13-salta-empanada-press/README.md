# Files · 13 · Salta empanada press

The press clerk in Salta uploads the morning card, finds it, asks about
Ines, and downloads the bytes. Lot SLA-2026-1016-E2 still folds at 07:05.

**What it teaches**

- Capstone: upload, find, ask, download.
- Four HTTP calls.
- The mill copy and the brief agree on the lot code.

**Files**

| File | Role |
| --- | --- |
| [`empanada_press.rb`](empanada_press.rb) | Runs the desk |
| [`empanada_press_test.rb`](empanada_press_test.rb) | Checks the four calls |
| [`empanada-press.pdf`](empanada-press.pdf) | The press card |
| [`cassettes/empanada_press.yml`](cassettes/empanada_press.yml) | Files, find, Responses, download |

**Try it**

```sh
bundle exec ruby features/26-files/13-salta-empanada-press/empanada_press.rb
bundle exec ruby features/26-files/13-salta-empanada-press/empanada_press_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
