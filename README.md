# RubyLLM Multivitamin

Thirteen samples of healthy code for each feature of the
[RubyLLM](https://rubyllm.com) gem. This is the RubyLLM sibling of
[Stimulus Multivitamin](https://github.com/mikeymicrophone/stimulus-multivitamin).

| Supplement Facts | |
| --- | --- |
| Serving size | 1 scenario |
| Servings per feature | 13 |
| Features | 13 |
| Scenarios | 169 |
| Bottled | 1 |
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

The bottle is not full yet: 13 features, 13 scenarios each, 1 of 169 bottled.
The rest are titled and waiting.

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
`Authorization` headers and `sk-or-v1-` tokens before a cassette is written.

Live runs still need a key in the process, because RubyLLM raises
`RubyLLM::ConfigurationError` before any HTTP call when the provider is
unconfigured. Cassette runs set a placeholder when `OPENROUTER_API_KEY` is
absent. That placeholder is not a credential.

The bottled tide-board cassette was hand-authored to the request shape
RubyLLM 2.1.1 sends OpenRouter. The response follows OpenRouter's chat
completion JSON, including `usage.cost`. Re-record it with `LIVE=1` before
treating the sentences as something a model said. See that scenario's README.

## Free models

Checked against OpenRouter's models API on 14 October 2026. Free slugs move.
Pass `provider: :openrouter` and `assume_model_exists: true` when a slug is
newer than RubyLLM's bundled registry. `openrouter/free` picks a model at
random, so the catalog pins a slug instead. That keeps a cassette stable.

| Feature | Default | Fallback |
| --- | --- | --- |
| Chat, streaming, history, tokens, errors | `nvidia/nemotron-3-super-120b-a12b:free` | `liquid/lfm-2.5-2.6b:free`, then `poolside/laguna-s-2.1:free` |
| Tools | same chat model (it advertises `tools` and `tool_choice`) | `liquid/lfm-2.5-2.6b:free` |
| Structured output | `nvidia/nemotron-3-super-120b-a12b:free` (`structured_outputs`) | `liquid/lfm-2.5-2.6b:free`, then `dots-studio/dots-3-note-preview:free` |
| Images in, and video in | `google/gemma-4-31b-it:free` | `google/gemma-4-26b-a4b-it:free`, then `dots-studio/dots-3-note-preview:free` (image, no video) |
| Audio in | `thinkingmachines/inkling:free` | `thinkingmachines/inkling-small:free`, then `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free` |
| PDF in | none of the `:free` chat models advertised `file` input | a paid PDF-capable model such as `claude-sonnet-5` or a Gemini model the [attachments guide](https://rubyllm.com/attachments/) names |
| Embeddings | `nvidia/llama-nemotron-embed-vl-1b-v2:free` (text and image) | `nvidia/nemotron-3-embed-1b:free` or `liquid/lfm-2.5-embedding-350m:free` for text; paid `google/gemini-embedding-2` when the input is audio, video, or a PDF |
| Image generation | no `:free` image model that day | paid `google/gemini-2.5-flash-image` on OpenRouter's images endpoint, which `RubyLLM.paint` already speaks |

`nvidia/nemotron-3.5-content-safety:free` accepts images and does not advertise
tools. Do not use it for a tool example. Gemma's free models advertise
`response_format` and do not advertise `structured_outputs`; schema examples
stay on a model that lists `structured_outputs`.

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

1. [Chat basics](features/01-chat-basics/) — 1 of 13 bottled
2. [Streaming](features/02-streaming/) — 0 of 13 bottled
3. [Tools](features/03-tools/) — 0 of 13 bottled
4. [Structured output](features/04-structured-output/) — 0 of 13 bottled
5. [Multimodal attachments](features/05-multimodal-attachments/) — 0 of 13 bottled
6. [Embeddings](features/06-embeddings/) — 0 of 13 bottled
7. [Image generation](features/07-image-generation/) — 0 of 13 bottled
8. [Models and providers](features/08-models-and-providers/) — 0 of 13 bottled
9. [Configuration and contexts](features/09-configuration-and-contexts/) — 0 of 13 bottled
10. [Rails integration](features/10-rails-integration/) — 0 of 13 bottled
11. [Instructions and history](features/11-instructions-and-history/) — 0 of 13 bottled
12. [Tokens and cost](features/12-tokens-and-cost/) — 0 of 13 bottled
13. [Error handling](features/13-error-handling/) — 0 of 13 bottled

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
