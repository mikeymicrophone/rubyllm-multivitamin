# Tokenization · 11 · Tromsø aurora proxy

Sigrid's Tromsø observatory sends its aurora-board text to a Qwen deployment behind
GPUStack's model proxy. The tokenizer URL strips the proxy's final /v1, and the returned
IDs stay available for adjacent-token inspection.

**What it teaches**

- GPUStack tokenization uses the model proxy route without its trailing /v1.
- assume_model_exists allows the observatory's locally deployed model name.
- A context supplies the proxy base; each_cons inspects neighbouring token IDs.

**Files**

| File | Role |
| --- | --- |
| [`aurora_proxy.rb`](aurora_proxy.rb) | Runs the desk |
| [`aurora_proxy_test.rb`](aurora_proxy_test.rb) | Checks the lesson and request shape |
| [`cassettes/aurora_proxy.yml`](cassettes/aurora_proxy.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/31-tokenization/11-tromso-aurora-proxy/aurora_proxy.rb
bundle exec ruby features/31-tokenization/11-tromso-aurora-proxy/aurora_proxy_test.rb
```

**Fixture provenance**

This cassette is hand-authored, not a live recording. Request bodies were captured by
running this script through the RubyLLM 2.1.1 encoder with WebMock blocking network
access. Responses use the provider protocol's JSON shape; token IDs, counts, and any
generated answers or usage are illustrative fixtures, not verified tokenizer output or
billed measurements. `recorded_at` is a fixture timestamp.

For a live run, set `GPUSTACK_API_BASE` to your deployment's `/model/proxy/ROUTE_ID/v1`
URL and deploy the named model there. The replay URL is
`http://localhost:8080/model/proxy/7/v1`; replay does not contact it. The hostname
keeps this request replayable alongside the timeout examples, which globally
exclude numeric `127.0.0.1` requests from VCR.

Re-record with `LIVE=1 GPUSTACK_API_KEY=... bundle exec ruby
features/31-tokenization/11-tromso-aurora-proxy/aurora_proxy.rb`. Leave `LIVE_PROVIDER`
unset; these scripts pin their provider and model. After recording, update this
provenance paragraph and validate any provider-dependent assertions.

**Model**

GPUStack `qwen2.5-7b-instruct`. API shapes checked against the installed RubyLLM 2.1.1
source; provider availability was not checked live.
