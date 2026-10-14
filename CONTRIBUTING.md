# Contributing to RubyLLM Multivitamin

Every scenario in this catalog follows the same conventions. The reference
scenario, [Chat basics · 01 · Point Wilson tide board](features/01-chat-basics/01-point-wilson-tide-board/),
follows all of them; copy its shape when you add a new one.

## The rules

### 1. Real names, always

This rule is not negotiable. Every class, method, file, folder, schema field,
tool, variable, and string a reader sees gets a name that means something in
the scenario's domain.

Never use `foo`, `bar`, `baz`, `qux`, `hello`, `hello world`, `example`,
`demo`, `test`, `thing`, `item1`, `my_tool`, `some_value`, `data`, `x`, or
similar stand-ins. If you are tempted to write one, the scenario is not
concrete enough yet.

| Instead of | Write |
| --- | --- |
| `class MyTool` | `class KelpLedgeClearance` |
| `def execute(query:)` | `def execute(station:, boat:)` |
| `chat.ask "Hello"` | `chat.ask` with the tide board pasted in |
| `name: "Alice"` | `name: "Alden"` when Alden is the foghorn tender |

Content counts too: use believable sample data (a posted tide board, a retort
cook card, a lens-cabinet drawer), not lorem ipsum.

Test files are named `*_test.rb` because Minitest loads them that way. The
word belongs to the runner, not to the domain. Inside the test, the names are
still the scenario's names.

### 2. One believable scenario per scenario folder

Each folder is one real-world job: a tide clerk briefing the watch, a lens
keeper inventorying a cabinet, a cannery clerk logging a retort cook. Pick a
scenario where the feature is the natural tool, not one bent to fit it.
Within a feature, the thirteen scenarios should each show the feature in a
different shape rather than repeat one pattern.

### 3. Moderately complex to complex

Skip what the official docs already cover in a few lines. A scenario should
have enough moving parts to show the feature under realistic pressure: a
follow-up that depends on the earlier turn, a tool the model has to choose,
a schema with nested fields, an attachment the job would actually hand over.
Order the thirteen slots roughly from moderate to complex. Other RubyLLM
features may appear when a real job would use them, but the folder's feature
must be the star.

### 4. A short comment header that says what it teaches

- The script opens with a comment: the feature, slot number, and scenario
  title, followed by a short "Teaches:" list.
- The scenario's `README.md` repeats the "What it teaches" list for readers
  browsing on GitHub, plus a table of files and a "Try it" section.

Inside the code, comment only on constraints the code cannot show. Do not
narrate what the next line does.

### 5. Pinned to RubyLLM 2.1.1

The root `Gemfile` pins `ruby_llm` to `2.1.1`, the version these scenarios
were checked against. Method names follow the guides on
[rubyllm.com](https://rubyllm.com) for that version. When a guide and an
older memory disagree, the guide wins: `ask` (and `say`), `with_instructions`,
`with_schema` and `Schematist::Schema`, `with_tools` and `RubyLLM::Tool`,
`RubyLLM.embed`, `RubyLLM.paint`, `acts_as_chat` and `acts_as_message`,
`response.tokens`, `response.cost`, `RubyLLM.context`.

When a new stable release ships, bump it in one commit: the `Gemfile`, the
"Supplement Facts" in `README.md`, and this file. Re-run the bottled tests
against cassettes. Re-record a cassette only when the request body actually
changed.

### 6. Thirteen per feature, and a quirked-safe folder

Each feature folder holds thirteen slots. A slot is bottled when its folder
contains a script, a test, a README, and a cassette (or a test that truly
makes no HTTP call, which still gets a README saying so). Until then the
feature README lists the title as planned.

A future `quirked` branch will keep every RubyLLM technique and the same
thirteen-per-feature structure, but swap the scenarios for more obscure,
esoteric, and playful subject matter: still readable and real, never
gibberish. Rule 1 applies there too.

To make that reskin a matter of renaming rather than restructuring, keep each
scenario self-contained:

- Scenario-specific names, copy, and sample data live only in that
  scenario's folder (its script, test, README, fixtures, and cassettes),
  never in `support/` or the root README's how-to-run section.
- Put the RubyLLM lesson in the structure (which calls happen, in what
  order, what the test asserts about roles and usage), not in domain
  details, so a new domain can map onto the same structure one name at a
  time.
- `support/models.rb` holds provider model slugs. Those are not scenario
  copy. `support/cassettes.rb` holds the player. Neither file should mention
  a station, a boat, or a cabinet.

## Cassettes

- Default is replay. `LIVE=1` records with `record: :all` and overwrites the
  scenario's cassette. Matching is method, URI, and body, so a drift in the
  request fails the test instead of returning a stale reply.
- The cassette file lives in the scenario folder at `cassettes/<name>.yml`.
  The script and the test both call `Multivitamin::Cassettes.play(__dir__, name)`.
- Set `config.max_retries = 0` on examples that record a fixed number of
  calls, unless the scenario is about retries. Faraday will otherwise repeat
  a failed POST and the cassette grows a second interaction.
- Filter secrets. The helper replaces `Authorization` and a list of provider
  key environment variables, and it scrubs `sk-or-v1-` tokens from bodies.
  Add a new provider key to `Multivitamin::Cassettes::KEY_ENV_VARS` when a
  scenario starts using it. A test should read the cassette and refute a
  live key pattern, the way the tide board test does.
- Never commit `.env` or a raw key. `.env.example` stays empty.
- A hand-authored cassette is allowed when no key is available. Build the
  request body by running the script's encoder and write a response in the
  provider's real JSON shape. Say so in the scenario README, and say that
  `LIVE=1` should re-record it.
- Live runs default to the free OpenRouter slug in `support/models.rb` and
  the feature README. If that slug is gone, use the documented fallback and
  update both places in the same commit.

## Rails scenarios

A Rails scenario keeps its app inside the scenario folder: models, a tiny
schema, the script or test that boots it. Add `rails` to the root `Gemfile`
in the commit that bottles the first one, so `rake test` stays a single
command. Do not put station names into a shared initializer.

`acts_as_chat` and `acts_as_message` are the application API. RubyLLM owns
`ruby_llm_models`, `ruby_llm_tool_calls`, `ruby_llm_usages`,
`ruby_llm_batches`, `ruby_llm_mcp_credentials`, and
`ruby_llm_provider_files`. Do not invent an application `Model` or `ToolCall`
class. Allow assistant messages with empty content.

## Adding a scenario

1. Pick the next open slot in the feature's `README.md`. The planned titles
   are proposals; replace one if you have a better scenario.
2. Create the scenario folder following the reference scenario.
3. In the feature's `README.md`, link the slot, mark it "available", and
   update the "N of 13 bottled" count.
4. In the root `README.md`, update that feature's "N of 13 bottled" count
   and the bottle's "Bottled" fact.
5. Run `bundle exec ruby` on the script and the test with no key, then
   `bundle exec rake test`.
