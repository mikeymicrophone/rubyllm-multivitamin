# Audio transcription · 04 · Freshwater Bay vocabulary prompt

The mate at Freshwater Bay files a Dungeness Spit kelp-ledge tape. The
`prompt:` lists the spellings the chart desk already uses: Dungeness Spit,
kelp ledge, MLLW, and Fresnel.

**What it teaches**

- `prompt:` is vocabulary and formatting guidance, not a chat question.
- The cassette multipart body includes those chart names.
- `gpt-transcribe` keeps Dungeness, kelp, and Fresnel in `text`.

**Files**

| File | Role |
| --- | --- |
| [`freshwater_vocab.rb`](freshwater_vocab.rb) | Transcribes the kelp-ledge tape with a prompt |
| [`freshwater_vocab_test.rb`](freshwater_vocab_test.rb) | Replays the cassette |
| [`freshwater-bay-vocab.mp3`](freshwater-bay-vocab.mp3) | Short spoken fixture |
| [`cassettes/freshwater_vocab.yml`](cassettes/freshwater_vocab.yml) | Live OpenAI recording of `gpt-transcribe` |

**Try it**

```sh
bundle exec ruby features/16-audio-transcription/04-freshwater-bay-vocabulary/freshwater_vocab_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/16-audio-transcription/04-freshwater-bay-vocabulary/freshwater_vocab_test.rb
```

**Model**

Recorded on `gpt-transcribe` with `prompt:` set.
