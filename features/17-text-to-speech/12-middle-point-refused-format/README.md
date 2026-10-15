# Text to speech · 12 · Middle Point refused format

The inlet watch at Middle Point, on Admiralty Inlet, asked for an AIFF
hail. `tts-1` refuses that container.

**What it teaches**

- `format: "aiff"` raises `RubyLLM::BadRequestError`.
- The message is `Invalid response_format`.
- The cassette is HTTP 400. There is no audio payload to shrink.
  `max_retries` stays 0 so Faraday does not double the 400.

**Files**

| File | Role |
| --- | --- |
| [`middle_refusal.rb`](middle_refusal.rb) | Asks for AIFF and rescues the 400 |
| [`middle_refusal_test.rb`](middle_refusal_test.rb) | Replays the cassette |
| [`cassettes/middle_refusal.yml`](cassettes/middle_refusal.yml) | Live OpenAI 400 |

**Try it**

```sh
bundle exec ruby features/17-text-to-speech/12-middle-point-refused-format/middle_refusal_test.rb
```

Re-record with `LIVE=1 LIVE_PROVIDER=openai`. Do not hand-author the cassette.

**Model**

Recorded on `tts-1` with `provider: :openai` and `format: "aiff"`.
Supported formats on this endpoint are `mp3`, `opus`, `aac`, `flac`,
`wav`, and `pcm`.
