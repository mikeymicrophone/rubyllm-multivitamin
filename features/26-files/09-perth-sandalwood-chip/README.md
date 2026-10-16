# Files · 09 · Perth sandalwood chip

The oil clerk in Perth has the chip card in memory, not on disk. An IO
upload needs `filename:` so OpenAI stores `sandalwood-chip.pdf`.

**What it teaches**

- Pass `filename:` for an IO.
- `purpose:` is still required.
- The stored name is the one you sent.

**Files**

| File | Role |
| --- | --- |
| [`sandalwood_chip.rb`](sandalwood_chip.rb) | Uploads a StringIO |
| [`sandalwood_chip_test.rb`](sandalwood_chip_test.rb) | Checks the filename |
| [`sandalwood-chip.pdf`](sandalwood-chip.pdf) | Bytes for the IO |
| [`cassettes/sandalwood_chip.yml`](cassettes/sandalwood_chip.yml) | The Files POST |

**Try it**

```sh
bundle exec ruby features/26-files/09-perth-sandalwood-chip/sandalwood_chip.rb
bundle exec ruby features/26-files/09-perth-sandalwood-chip/sandalwood_chip_test.rb
```

Re-record with `LIVE=1 OPENAI_API_KEY=...`. Checked 16 October 2026.
