# Batches · 03 · Galle lace-bobbin pending nil slots

The bobbin clerk in Galle stages two lace cards. `messages` is two slots;
a pending request is `nil` in its slot.

**What it teaches**

- `messages` is an array the same length as the submitted chats.
- A slot is `nil` while that request has no result yet.
- Failed slots stay `nil` after the batch ends.

**Files**

| File | Role |
| --- | --- |
| [`lace_bobbin.rb`](lace_bobbin.rb) | Submits two bobbin cards and reads messages |
| [`lace_bobbin_test.rb`](lace_bobbin_test.rb) | Replays the cassette and checks the nil slots |
| [`cassettes/lace_bobbin.yml`](cassettes/lace_bobbin.yml) | Upload, create, and result poll |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/21-batches/03-galle-lace-bobbin/lace_bobbin.rb
bundle exec ruby features/21-batches/03-galle-lace-bobbin/lace_bobbin_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/21-batches/03-galle-lace-bobbin/lace_bobbin.rb
```

**Model**

OpenAI Batch on `gpt-4.1-mini`. Free OpenRouter slugs usually have no batch access. Checked 16 October 2026.
