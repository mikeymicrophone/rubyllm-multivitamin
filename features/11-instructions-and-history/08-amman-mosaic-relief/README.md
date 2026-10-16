# Instructions and history · 08 · Amman mosaic afternoon relief replaces orders

The morning floor clerk at the Haddad mosaic workshop in Jabal Amman
logs a shut floor and an 18.4 kg tesserae bin, then the afternoon relief
replaces those standing orders before writing the crew note.

**What it teaches**

- A second `with_instructions` replaces every system message.
- In RubyLLM 2.1.1 the replacement is appended at the end of
  `chat.messages`, so the roles just after the swap are
  `[:user, :assistant, :system]`.
- The encoder still lifts that system text into the next request. The
  morning orders are gone from the wire.

**Files**

| File | Role |
| --- | --- |
| [`mosaic_relief.rb`](mosaic_relief.rb) | Morning ask, replace orders, afternoon note |
| [`mosaic_relief_test.rb`](mosaic_relief_test.rb) | Replays the cassette and checks the swap |
| [`cassettes/mosaic_relief.yml`](cassettes/mosaic_relief.yml) | Live recording of both asks |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/08-amman-mosaic-relief/mosaic_relief.rb
bundle exec ruby features/11-instructions-and-history/08-amman-mosaic-relief/mosaic_relief_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/08-amman-mosaic-relief/mosaic_relief.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
