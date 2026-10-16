# Batches · 13 · Vientiane pha-nung desk capstone

The cloth clerk in Vientiane stages two pha nung cards for Khamla, submits
the batch, finds it by id, and refreshes once.

**What it teaches**

- A desk can stage two chats, submit, find, and refresh once.
- `statuses` is empty until results arrive; `messages` keeps one slot per chat.

**Files**

| File | Role |
| --- | --- |
| [`pha_nung.rb`](pha_nung.rb) | Stages two cards, submits, finds, and refreshes |
| [`pha_nung_test.rb`](pha_nung_test.rb) | Replays the cassette and checks the desk |
| [`cassettes/pha_nung.yml`](cassettes/pha_nung.yml) | Upload, create, find, refresh, and messages |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/13-vientiane-pha-nung/pha_nung.rb
bundle exec ruby features/21-batches/13-vientiane-pha-nung/pha_nung_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/13-vientiane-pha-nung/pha_nung.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
