# Batches · 11 · Ohrid pearl-nacre poll job

The nacre clerk in Ohrid files 21 blanks for Zlata. A job calls
`refresh` once and reads the new status.

**What it teaches**

- `refresh` re-fetches status. It does not loop by itself.
- A job that polls should call `refresh` once per tick.

**Files**

| File | Role |
| --- | --- |
| [`pearl_nacre.rb`](pearl_nacre.rb) | Submits the nacre card and refreshes once |
| [`pearl_nacre_test.rb`](pearl_nacre_test.rb) | Replays the cassette and checks both statuses |
| [`cassettes/pearl_nacre.yml`](cassettes/pearl_nacre.yml) | Upload, create, and one refresh |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/11-ohrid-pearl-nacre/pearl_nacre.rb
bundle exec ruby features/21-batches/11-ohrid-pearl-nacre/pearl_nacre_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/11-ohrid-pearl-nacre/pearl_nacre.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
