# Batches · 02 · Plovdiv rose-attar Batch.find

The attar clerk in Plovdiv files 22 flasks for Nevena, persists the batch
id, then picks the batch back up with `Batch.find`.

**What it teaches**

- Persist `batch.id`, then `Batch.find(id, provider:)` from another process.
- The found batch carries the same id and a fresh status.

**Files**

| File | Role |
| --- | --- |
| [`rose_attar.rb`](rose_attar.rb) | Submits the attar card and finds it by id |
| [`rose_attar_test.rb`](rose_attar_test.rb) | Replays the cassette and checks the ids match |
| [`cassettes/rose_attar.yml`](cassettes/rose_attar.yml) | Upload, create, and find |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/02-plovdiv-rose-attar/rose_attar.rb
bundle exec ruby features/21-batches/02-plovdiv-rose-attar/rose_attar_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/02-plovdiv-rose-attar/rose_attar.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
