# Configuration and contexts · 06 · Kaohsiung wafer-fab logger

The night NOC at Southern Taiwan Science Park in Kaohsiung sends the
06:00 etch-tool uptime round through a `Logger` bound to a `StringIO`.
The floor can read that IO. `RUBYLLM_DEBUG` is not set.

**What it teaches**

- `config.logger` is the Logger Faraday writes to when `RubyLLM.logger`
  points at it.
- Setting `logger` overrides `log_file` and `log_level` on Configuration.
- `RubyLLM.logger` is memoized. A later `configure` that assigns a new
  Logger does not take effect until that memo is cleared.

**Files**

| File | Role |
| --- | --- |
| [`fab_logger.rb`](fab_logger.rb) | Configures a StringIO logger and asks the uptime round |
| [`fab_logger_test.rb`](fab_logger_test.rb) | Replays the cassette and reads the log IO |
| [`cassettes/fab_logger.yml`](cassettes/fab_logger.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/09-configuration-and-contexts/06-kaohsiung-fab-logger/fab_logger.rb
bundle exec ruby features/09-configuration-and-contexts/06-kaohsiung-fab-logger/fab_logger_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/09-configuration-and-contexts/06-kaohsiung-fab-logger/fab_logger.rb
```

**Model**

Recorded on the free OpenRouter chat slug when the daily cap allows.
`CONFIGURATION_OPENROUTER_PAID=1` records `openai/gpt-4.1-mini` on
OpenRouter. A 512-token output cap is set so a paid request fits this
workspace's credits. Fallback: `LIVE_PROVIDER=openai` records native
`gpt-4.1-mini`.
