# Tokenization · 05 · Zanzibar dhow manifest

Asha checks whether dhow Mwangaza can load spice crates at Stone Town. A berth-ledger
class and a cargo-hold instance are both registered, so Anthropic's count includes their
argument schemas even though neither tool runs.

**What it teaches**

- Anthropic counts function tool definitions without executing the tools.
- with_tools registers a class and a stateful instance together; parameters do declares
  schemas.
- each_with_object projects the registered tools into a manifest index.

**Files**

| File | Role |
| --- | --- |
| [`dhow_manifest.rb`](dhow_manifest.rb) | Runs the desk |
| [`dhow_manifest_test.rb`](dhow_manifest_test.rb) | Checks the lesson and request shape |
| [`cassettes/dhow_manifest.yml`](cassettes/dhow_manifest.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/05-zanzibar-dhow-manifest/dhow_manifest.rb
bundle exec ruby features/31-tokenization/05-zanzibar-dhow-manifest/dhow_manifest_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

Re-record with `LIVE=1 ANTHROPIC_API_KEY=... bundle exec ruby
features/31-tokenization/05-zanzibar-dhow-manifest/dhow_manifest.rb`. Leave
`LIVE_PROVIDER` unset; these scripts pin their provider and model. After recording,
update this provenance paragraph and validate any provider-dependent assertions.

**Model**

Anthropic `claude-sonnet-4-6`. API shapes checked against the installed RubyLLM 2.1.1
source; provider availability was not checked live.
