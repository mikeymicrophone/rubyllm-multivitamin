# Configuration and contexts · 06 · Smith Island logger

The keeper at Smith Island Light sends the 06:00 weather round through a
`Logger` bound to a `StringIO`. The watch can read that IO. `RUBYLLM_DEBUG`
is not set.

**What it teaches**

- `config.logger` is the Logger Faraday writes to when `RubyLLM.logger`
  points at it.
- Setting `logger` overrides `log_file` and `log_level` on Configuration.
- `RubyLLM.logger` is memoized. A later `configure` that assigns a new
  Logger does not take effect until that memo is cleared.

**Files**

| File | Role |
| --- | --- |
| [`weather_logger.rb`](weather_logger.rb) | Configures a StringIO logger and asks the weather round |
| [`weather_logger_test.rb`](weather_logger_test.rb) | Replays the cassette and reads the log IO |
| [`cassettes/weather_logger.yml`](cassettes/weather_logger.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/06-smith-island-logger/weather_logger.rb
bundle exec ruby features/09-configuration-and-contexts/06-smith-island-logger/weather_logger_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/06-smith-island-logger/weather_logger.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
