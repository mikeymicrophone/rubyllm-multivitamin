# Tools · 09 · Hallstatt salt-mine face

The first sentence of the question names the Salzburg visitor office.
The face the clerk must look up is later: Hallstatt, Kaiserin Elisabeth,
38 m. The model has to pass that station name into `face_card`.

**What it teaches**

- The station the tool needs can sit later in the question.
- The first sentence is a decoy. A test locks that it does not contain
  `Hallstatt`.

**Files**

| File | Role |
| --- | --- |
| [`mine_face.rb`](mine_face.rb) | Asks a question whose first sentence names Salzburg |
| [`mine_face_test.rb`](mine_face_test.rb) | Checks the tool argument and replays the cassette |
| [`cassettes/mine_face.yml`](cassettes/mine_face.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/09-hallstatt-salt-face/mine_face_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/09-hallstatt-salt-face/mine_face_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
