# Video generation

`RubyLLM.animate` submits a job, waits, and returns a `RubyLLM::Video` (`url`, `data`, `mime_type`, `duration`, `model`, `save`, `to_blob`). `animate_later` returns a `RubyLLM::VideoJob` (`id`, `status`, `refresh`, `wait`, `video`, `cost`). `with:` animates a still. `extend:` continues a clip. `provider_options:` carry duration and resolution. Timeouts are `video_generation_timeout` and `video_generation_poll_interval`.

Official reference: [Video Generation](https://rubyllm.com/video-generation/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.animate "A paper boat..."`
- `RubyLLM.animate_later` → `RubyLLM::VideoJob`
- `job.refresh`, `wait`, `video`, `cost`
- `with:` image-to-video, `extend:` continue a clip
- `provider_options:` duration / resolution
- `video.save` / `to_blob`

## Providers that can record it

xAI (`grok-imagine-video`, edit and extend). Gemini Veo (`veo-3.1-fast-generate-preview`). Vertex AI Veo (`assume_model_exists: true`, GCS). Bedrock Luma Ray. ElevenLabs Creatify Aurora (image + audio). GPUStack for self-hosted. OpenAI does not generate video in 2.1.1. There is no `:free` video model in this catalog. Record on xAI or Gemini; both are paid.

## Examples (0 of 13 bottled)

01. Fort Casey paper boat — planned
02. Admiralty Head animate_later poll — planned
03. Bush Point waterfall still — planned
04. Lagoon Point first and last frame — planned
05. Mutiny Bay xAI edit — planned
06. Useless Bay extend two seconds — planned
07. Double Bluff Veo 720p — planned
08. Hood Head Vertex storageUri — planned
09. Tala Point Aurora character — planned
10. Termination Point job.cost — planned
11. Port Ludlow timeout leaves job running — planned
12. Dabob Bay Active Storage trailer — planned
13. Quilcene channel clip capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
