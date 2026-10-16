# Files · 05 · Lae copra sheet

The kiln clerk in Lae asks about a small copra sheet with automatic
uploads left on. OpenAI's inline limit is 50 MiB. The sheet stays on the
request as `file_data`. There is no Files POST.

**What it teaches**

- `auto_upload_large_files` is on by default.
- A sheet under the 50 MiB threshold is not uploaded.
- Naomi and lot LAE-2026-1016-C4 still land in the brief.

**Files**

| File | Role |
| --- | --- |
| [`copra_sheet.rb`](copra_sheet.rb) | Asks with the sheet inline |
| [`copra_sheet_test.rb`](copra_sheet_test.rb) | Checks there is no Files POST |
| [`copra-sheet.pdf`](copra-sheet.pdf) | The kiln sheet |
| [`cassettes/copra_sheet.yml`](cassettes/copra_sheet.yml) | One Responses POST |

**Try it**

```sh
bundle exec ruby features/26-files/05-lae-copra-sheet/copra_sheet.rb
bundle exec ruby features/26-files/05-lae-copra-sheet/copra_sheet_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
