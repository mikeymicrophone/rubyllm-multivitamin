source "https://rubygems.org"

ruby ">= 3.2"

# Pinned to the version the catalog was checked against.
# https://rubyllm.com/getting-started/
gem "ruby_llm", "2.1.1"

gem "minitest", "~> 5.25"
gem "rake", "~> 13.2"
gem "vcr", "~> 6.3"
gem "webmock", "~> 3.24"
gem "webrick", "~> 1.8"

# Local, synchronous trace export for feature 33; no OTLP service required.
gem "opentelemetry-sdk", "1.7.0"

# Rails integration scenarios boot an in-memory SQLite schema. Not a
# full Rails application. See features/10-rails-integration/.
gem "activerecord", "~> 8.0"
gem "sqlite3", "~> 2.6"
# Durable jobs and ActiveJob::Continuable require Rails 8.1 or newer.
gem "activejob", "~> 8.1"
