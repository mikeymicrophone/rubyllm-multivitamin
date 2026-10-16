# Moderation · 05 · Durban bunny chow

The counter clerk in Durban pins `omni-moderation-2024-09-26` so a replay
of last winter's hail uses the same id. The bunny-chow card is clean on
that pin. Mistral needs a key this catalog does not have.

**What it teaches**

- `model:` selects a moderation id. It is not always the default latest
  alias.
- The pinned id is in the request body. `latest` is not.
- A clean counter hail is still not flagged.

**Files**

| File | Role |
| --- | --- |
| [`bunny_chow.rb`](bunny_chow.rb) | Screens the hail on the pinned id |
| [`bunny_chow_test.rb`](bunny_chow_test.rb) | Checks the model id in the cassette |
| [`cassettes/bunny_chow.yml`](cassettes/bunny_chow.yml) | The Moderations call |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/23-moderation/05-durban-bunny-chow/bunny_chow.rb
bundle exec ruby features/23-moderation/05-durban-bunny-chow/bunny_chow_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/23-moderation/05-durban-bunny-chow/bunny_chow.rb
```

**Model**

`omni-moderation-2024-09-26` on OpenAI. Checked 16 October 2026.
