# Text to speech · 01 · Fort Worden welcome hail

The incoming watch at Fort Worden State Park wants a short hail for the
fog on the spit. One `RubyLLM.speak` call on `tts-1` returns a
`RubyLLM::Speech`. Station tide board:
<https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900>.

**What it teaches**

- `RubyLLM.speak` returns a `RubyLLM::Speech`.
- `model:` and `provider: :openai` select `tts-1`.
- The omitted `voice:` is sent as `"alloy"`. The omitted `format:` is
  `"mp3"` on the returned object. The request does not contain
  `response_format`.
- `mime_type` is `"audio/mpeg"`. The bytes start with an MPEG frame sync.

**Files**

| File | Role |
| --- | --- |
| [`welcome_hail.rb`](welcome_hail.rb) | Speaks the spit hail |
| [`welcome_hail_test.rb`](welcome_hail_test.rb) | Replays the cassette |
| [`cassettes/welcome_hail.yml`](cassettes/welcome_hail.yml) | Live OpenAI recording of `tts-1` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/17-text-to-speech/01-fort-worden-welcome-hail/welcome_hail_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/17-text-to-speech/01-fort-worden-welcome-hail/welcome_hail_test.rb
```

The helper strips `Authorization` and replaces large speech payloads with
a short silent MP3. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai`. Confirmed on
`https://api.openai.com/v1/models` on 15 October 2026 as the cheapest
OpenAI speech model.
