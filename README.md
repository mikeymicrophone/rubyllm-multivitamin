# RubyLLM Multivitamin

Thirteen samples of healthy code for each feature of the
[RubyLLM](https://rubyllm.com) gem. This is the RubyLLM sibling of
[Stimulus Multivitamin](https://github.com/mikeymicrophone/stimulus-multivitamin).

| Supplement Facts | |
| --- | --- |
| Serving size | 1 scenario |
| Servings per feature | 13 |
| Features | 33 |
| Scenarios | 429 |
| Bottled | 247 |
| Active ingredient | RubyLLM 2.1.1 |
| Default run | cassettes |

## Why

The official RubyLLM guides explain each feature well, but most of their
snippets are deliberately small: a greeting, a weather tool, a person named
Alice. That is enough to learn the method names and not enough to see how a
feature holds up inside a real job of work.

RubyLLM Multivitamin is a catalog of realistic scenarios: a tide board at
Point Wilson, a Fresnel lens cabinet, a cannery retort log. Each feature gets
thirteen of them, ranging from moderately complex to complex, so you can see
the same feature applied in thirteen different shapes.

Every scenario uses real, domain-meaningful names. You will not find
placeholder names here.

The catalog is 33 features, 13 scenarios each, 429 slots. 247 of 429 are
bottled. Features 1–19 are full. Features 20–33 have stub READMEs.
MCP client chats were recorded on OpenAI `gpt-4.1-mini`, except Juan de Fuca
deferred tool search which used `gpt-5.4-mini`. Audio transcription was
recorded on OpenAI `gpt-transcribe`, `whisper-1`, and
`gpt-4o-transcribe-diarize`. Text to speech was recorded on OpenAI `tts-1`.
Provider tools and citations were recorded on OpenAI `gpt-4.1-mini`.
Tools, tool approval and loop control, the Point Wilson spoken handover, the
schema turns, the attachment scenarios, and the Rails integration chats
were recorded on OpenAI `gpt-4.1-mini`.
Decisions calls in the structured-output feature were recorded on OpenAI
`gpt-6-luna`. Audio attachments were recorded on OpenAI `gpt-audio-mini`.
Embedding text cassettes were recorded on OpenAI `text-embedding-3-small`.
The Smith Island barometer card was recorded on OpenRouter
`google/gemini-embedding-2`. Image generation was recorded on OpenAI
`gpt-image-1-mini`. Models-and-providers chats and the
instructions-and-history cassettes were recorded on OpenAI `gpt-4.1-mini`
(and `gpt-4o-mini` for the mid-chat switch) after the free OpenRouter slugs
hit the daily cap. The registry `refresh` cassette is the published catalog
on rubyllm.com. Configuration and contexts were recorded on OpenRouter
`openai/gpt-4.1-mini` (and `openai/gpt-4.1-nano`) after the `:free` slugs hit
the daily cap; the Juan de Fuca context embed also records OpenAI
`text-embedding-3-small` for the global call. Tokens and cost were recorded
on OpenRouter `nvidia/nemotron-3-super-120b-a12b:free` after the 8 PM ET
reset on 15 October 2026, except Sequim Bay which fell back to OpenAI
`gpt-4.1-mini` after `free-models-per-day`. Error handling recorded a
rejected-key 401 and a `free-models-per-day` 429 on OpenRouter, and schema,
embedding-overflow, tool, cancel, and fallback cassettes on OpenAI
`gpt-4.1-mini` (and `text-embedding-3-small`). Agents recorded OpenAI
`gpt-4.1-mini` after the free OpenRouter slug hit `free-models-per-day`
(and `gpt-4o-mini` for the Port Angeles mid-run switch). Neah Bay records
`openai/gpt-4.1-mini` on OpenRouter so the cassette keeps `X-OpenRouter-Title`.
Friday Harbor and Bremerton record unlisted-OpenRouter 400s; Friday Harbor
hops to OpenAI when `on:` lists `BadRequestError`. The other
bottled cassettes are OpenRouter.

## Run the examples

```sh
bundle install
bundle exec rake test
```

`rake test` runs every bottled example against the cassette in its own
folder. Nothing calls a provider. No API key is required. Ruby 3.2 or newer.

Run one example on its own:

```sh
bundle exec ruby features/01-chat-basics/01-point-wilson-tide-board/tide_briefing.rb
bundle exec ruby features/01-chat-basics/01-point-wilson-tide-board/tide_briefing_test.rb
```

The script prints the watch brief. The test checks the brief, the transcript
roles, and the token counts.

### Cassettes and live runs

Cassettes are the default. [VCR](https://github.com/vcr/vcr) and WebMock replay
the recorded HTTP calls, matched on method, URI, and body. A request the
cassette does not already answer fails the run.

`LIVE=1` turns recording on and overwrites the cassette for each example you
run:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec rake test
```

Copy [`.env.example`](.env.example) to `.env` if you want the key next to the
repo. `.env` is gitignored. Never commit a key. The cassette helper strips
`Authorization` headers, `OPENROUTER_API_KEY`, `OPENAI_API_KEY`, `sk-or-v1-`
tokens, and other `sk-` tokens before a cassette is written.

Live runs still need a key in the process, because RubyLLM raises
`RubyLLM::ConfigurationError` before any HTTP call when the provider is
unconfigured. Cassette runs set a placeholder when the key is absent. That
placeholder is not a credential.

`LIVE_PROVIDER=openai` or `LIVE_PROVIDER=openrouter` overrides the provider
while `LIVE=1` is recording, for examples that call `Multivitamin::Models.chat`.
Replay ignores `LIVE_PROVIDER`, so the cassette body still matches.

Chat basics and the earlier streaming cassettes are live OpenRouter
recordings. Tools, the spoken handover, structured output, the
attachment scenarios, the embedding text cassettes, image generation,
text to speech, provider tools and citations, and tool approval are live OpenAI recordings. The Smith Island barometer card is a live
OpenRouter recording. `usage.cost` is the number the provider reported.
See each scenario's README.

## Free models

Checked against OpenRouter's models API on 14 October 2026. Free slugs move.
Pass `provider: :openrouter` and `assume_model_exists: true` when a slug is
newer than RubyLLM's bundled registry. `openrouter/free` picks a model at
random, so the catalog pins a slug instead. That keeps a cassette stable.

| Feature | Default | Fallback |
| --- | --- | --- |
| Chat, streaming, history, tokens, errors, agent chat macros | `nvidia/nemotron-3-super-120b-a12b:free` | `liquid/lfm-2.5-2.6b:free`, then `poolside/laguna-s-2.1:free` |
| Agents with tools, schema, or `chat_model` (recorded) | `gpt-4.1-mini` on OpenAI (`provider: :openai`) | `nvidia/nemotron-3-super-120b-a12b:free` via `LIVE_PROVIDER=openrouter`, then `liquid/lfm-2.5-2.6b:free` |
| Tools (recorded) | `gpt-4.1-mini` on OpenAI (`provider: :openai`) | `nvidia/nemotron-3-super-120b-a12b:free` via `LIVE_PROVIDER=openrouter`, then `liquid/lfm-2.5-2.6b:free` |
| Tool approval and loop control (recorded) | `gpt-4.1-mini` on OpenAI (`provider: :openai`) | `nvidia/nemotron-3-super-120b-a12b:free` via `LIVE_PROVIDER=openrouter`, then `liquid/lfm-2.5-2.6b:free` |
| Spoken handover (recorded) | `gpt-4.1-mini` on OpenAI (`provider: :openai`) | same free chat model via `LIVE_PROVIDER=openrouter` |
| Structured output (recorded) | `gpt-4.1-mini` on OpenAI (`provider: :openai`) | `nvidia/nemotron-3-super-120b-a12b:free` via `LIVE_PROVIDER=openrouter`, then `liquid/lfm-2.5-2.6b:free` |
| Decisions inside structured output (recorded) | `gpt-6-luna` on OpenAI Decisions (`RubyLLM::Judge`, `POST /v1/decisions`) | none. `LIVE_PROVIDER` does not retarget a Judge. There is no separate Luna key |
| Images in, and video in | `google/gemma-4-31b-it:free` | `google/gemma-4-26b-a4b-it:free`, then `dots-studio/dots-3-note-preview:free` (image, no video) |
| Audio in | `thinkingmachines/inkling:free` | `thinkingmachines/inkling-small:free`, then `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free` |
| PDF in | none of the `:free` chat models advertised `file` input | `gpt-4.1-mini` on OpenAI, which the attachment scenarios recorded. The free vision and audio slugs were past the daily cap that afternoon, so those cassettes use `gpt-4.1-mini` and `gpt-audio-mini` as well |
| Embeddings (recorded) | `text-embedding-3-small` on OpenAI (`provider: :openai`) | `nvidia/nemotron-3-embed-1b:free` via `LIVE_PROVIDER=openrouter`, then `liquid/lfm-2.5-embedding-350m:free`. Image `with:` recorded on paid `google/gemini-embedding-2` |
| Image generation (recorded) | no `:free` image model that day | bottled on OpenAI `gpt-image-1-mini` (`quality: "low"`, `size: "1024x1024"`); OpenRouter paid fallback `google/gemini-2.5-flash-image` |
| Audio transcription (recorded) | no `:free` transcription slug used | bottled on OpenAI `gpt-transcribe`, `whisper-1`, and `gpt-4o-transcribe-diarize` |
| Text to speech (recorded) | no `:free` speech model that day | bottled on OpenAI `tts-1`; `LIVE_PROVIDER` does not retarget speech |
| Provider tools and citations (recorded) | no `:free` hosted-tool slug used | bottled on OpenAI `gpt-4.1-mini`; `:web_fetch` raises before HTTP on Responses |

`nvidia/nemotron-3.5-content-safety:free` accepts images and does not advertise
tools. Do not use it for a tool example. Gemma's free models advertise
`response_format` and do not advertise `structured_outputs`; schema examples
stay on a model that lists `structured_outputs`.

`gpt-4.1-mini` was confirmed on `https://api.openai.com/v1/models` on
14 October 2026. `gpt-4.1-nano` is cheaper and shuts down on 2026-10-23.
`gpt-5-nano` is cheaper, does not take temperature, and is a reasoning model.
The tools cassettes, the spoken handover, the schema turns, and the
attachment scenarios use `gpt-4.1-mini` for that reason. Audio attachments
use `gpt-audio-mini`. Decisions turns use `gpt-6-luna` because that is the
model OpenAI's Decisions API accepts. RubyLLM reaches it with
`RubyLLM::Judge` and `OPENAI_API_KEY`. Embedding text cassettes use
`text-embedding-3-small`. Image generation uses `gpt-image-1-mini`.
Audio transcription uses `gpt-transcribe`, `whisper-1`, and
`gpt-4o-transcribe-diarize`. Text to speech uses `tts-1`. Provider tools
and citations, and tool approval, use `gpt-4.1-mini`. See
[Structured output](features/04-structured-output/),
[Multimodal attachments](features/05-multimodal-attachments/),
[Embeddings](features/06-embeddings/),
[Image generation](features/07-image-generation/),
[Audio transcription](features/16-audio-transcription/),
[Text to speech](features/17-text-to-speech/),
[Provider tools and citations](features/18-provider-tools-and-citations/), and
[Tool approval and loop control](features/19-tool-approval-and-loop-control/).

Each feature README repeats the row that belongs to it.

## Layout

```
Rakefile                           runs features/**/*_test.rb against cassettes
support/cassettes.rb               VCR + WebMock, LIVE=1, key filtering
support/models.rb                  free-model slugs (not scenario copy)
features/
  01-chat-basics/
    README.md                      what the feature covers, and its 13 slots
    01-point-wilson-tide-board/
      tide_briefing.rb             the script
      tide_briefing_test.rb
      README.md
      cassettes/tide_briefing.yml
  02-streaming/
  ...
```

Each bottled scenario is self-contained: script, test, README, and cassettes
live in that folder, and so do the domain names and the copy. Shared files
hold the cassette player and the model slugs, not the story.

## Features

1. [Chat basics](features/01-chat-basics/) — 13 of 13 bottled
2. [Streaming](features/02-streaming/) — 13 of 13 bottled
3. [Tools](features/03-tools/) — 13 of 13 bottled
4. [Structured output](features/04-structured-output/) — 13 of 13 bottled
5. [Multimodal attachments](features/05-multimodal-attachments/) — 13 of 13 bottled
6. [Embeddings](features/06-embeddings/) — 13 of 13 bottled
7. [Image generation](features/07-image-generation/) — 13 of 13 bottled
8. [Models and providers](features/08-models-and-providers/) — 13 of 13 bottled
9. [Configuration and contexts](features/09-configuration-and-contexts/) — 13 of 13 bottled
10. [Rails integration](features/10-rails-integration/) — 13 of 13 bottled
11. [Instructions and history](features/11-instructions-and-history/) — 13 of 13 bottled
12. [Tokens and cost](features/12-tokens-and-cost/) — 13 of 13 bottled
13. [Error handling](features/13-error-handling/) — 13 of 13 bottled
14. [Agents](features/14-agents/) — 13 of 13 bottled
15. [MCP client](features/15-mcp-client/) — 13 of 13 bottled
16. [Audio transcription](features/16-audio-transcription/) — 13 of 13 bottled
17. [Text to speech](features/17-text-to-speech/) — 13 of 13 bottled
18. [Provider tools and citations](features/18-provider-tools-and-citations/) — 13 of 13 bottled
19. [Tool approval and loop control](features/19-tool-approval-and-loop-control/) — 13 of 13 bottled
20. [Evaluations](features/20-evaluations/) — 0 of 13 bottled
21. [Batches](features/21-batches/) — 0 of 13 bottled
22. [Video generation](features/22-video-generation/) — 0 of 13 bottled
23. [Moderation](features/23-moderation/) — 0 of 13 bottled
24. [Reranking](features/24-reranking/) — 0 of 13 bottled
25. [Document OCR](features/25-document-ocr/) — 0 of 13 bottled
26. [Files](features/26-files/) — 0 of 13 bottled
27. [Prompt caching](features/27-prompt-caching/) — 0 of 13 bottled
28. [Prompt rendering](features/28-prompt-rendering/) — 0 of 13 bottled
29. [Extended thinking](features/29-extended-thinking/) — 0 of 13 bottled
30. [Durable agents and Rails](features/30-durable-agents-and-rails/) — 0 of 13 bottled
31. [Tokenization](features/31-tokenization/) — 0 of 13 bottled
32. [Hosted research](features/32-hosted-research/) — 0 of 13 bottled
33. [OpenTelemetry](features/33-opentelemetry/) — 0 of 13 bottled

The reference scenario that later ones copy is
[Chat basics · 01 · Point Wilson tide board](features/01-chat-basics/01-point-wilson-tide-board/).

## Discoveries

Behaviors the official docs don't mention, found while bottling these
scenarios, are collected in [DISCOVERIES.md](DISCOVERIES.md). RubyLLM entries
are grouped by feature. Notes about running the examples, then provider
gotchas, sit after the feature sections. An entry lands there only after a
test in this repository has shown it.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the scenario conventions.

## License

[MIT](LICENSE) © Mike Schwab
