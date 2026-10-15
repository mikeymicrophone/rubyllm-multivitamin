# frozen_string_literal: true

# MCP client · 08 · Smith Island bearer and OAuth
#
# Teaches:
# - bearer_token sends Authorization on every Streamable HTTP request.
# - oauth grant: :client_credentials obtains a token after a 401 challenge.
# - Plain HTTP is allowed on loopback.

require "logger"
require "rbconfig"
require "ruby_llm"
require "socket"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SmithIslandMcpBearer
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)
  PORT = 18_765
  ENDPOINT = "http://127.0.0.1:#{PORT}/mcp"

  class SmithIslandBearerDesk < RubyLLM::MCP
    url ENDPOINT
    bearer_token { ENV.fetch("MCP_BEARER_TOKEN") }
  end

  class SmithIslandOauthDesk < RubyLLM::MCP
    url ENDPOINT
    oauth grant: :client_credentials,
          client_id: "smith-island-weather",
          client_secret: -> { ENV.fetch("MCP_CLIENT_SECRET") }
  end

  class WeatherToken
    INSTRUCTIONS = <<~TEXT.strip
      You are the weather clerk on Smith Island.
      Call barometer_glass once.
      Answer in one sentence. Include 29.92 inHg.
      Name the tender Alden.
    TEXT

    GLASS_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, afternoon watch on Smith Island.
      Station: https://www.nps.gov/places/smith-island-light-station.htm
      The foghorn tender Alden is standing off the kelp. What is the posted glass?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_content,
      :oauth_authorized,
      :oauth_tool_names,
      keyword_init: true
    )

    def self.conduct
      configure
      seed_tokens
      pid = start_desk
      bearer = SmithIslandBearerDesk.new
      oauth = SmithIslandOauthDesk.new
      oauth_tool_names = oauth.tools.map(&:name)
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(bearer)
      chat.with_tool_options(choice: "barometer_glass")
      answer = chat.ask(GLASS_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        oauth_authorized: oauth.authorized?,
        oauth_tool_names: oauth_tool_names
      )
    ensure
      bearer&.close
      oauth&.close
      stop_desk(pid)
    end

    def self.seed_tokens
      ENV["MCP_BEARER_TOKEN"] ||= "AdmiraltyBarometer-14Oct2026"
      ENV["MCP_CLIENT_SECRET"] ||= "SmithIslandGlass-secret"
      ENV["MCP_OAUTH_ACCESS_TOKEN"] ||= "SmithIslandOauth-round"
      ENV["MCP_CLIENT_ID"] ||= "smith-island-weather"
      ENV["MCP_HTTP_PORT"] ||= PORT.to_s
    end

    def self.start_desk
      pid = spawn(
        {
          "MCP_HTTP_PORT" => PORT.to_s,
          "MCP_BEARER_TOKEN" => ENV.fetch("MCP_BEARER_TOKEN"),
          "MCP_CLIENT_ID" => ENV.fetch("MCP_CLIENT_ID"),
          "MCP_CLIENT_SECRET" => ENV.fetch("MCP_CLIENT_SECRET"),
          "MCP_OAUTH_ACCESS_TOKEN" => ENV.fetch("MCP_OAUTH_ACCESS_TOKEN")
        },
        RbConfig.ruby, "-rbundler/setup", SERVER, PROFILE, "--http",
        out: File::NULL,
        err: File::NULL
      )
      wait_for_port
      pid
    end

    def self.wait_for_port
      50.times do
        Socket.tcp("127.0.0.1", PORT, connect_timeout: 0.2) { |socket| socket.close }
        return
      rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
        sleep 0.05
      end

      raise "Smith Island weather desk did not bind #{PORT}"
    end

    def self.stop_desk(pid)
      return unless pid

      Process.kill("TERM", pid)
      Process.wait(pid)
    rescue Errno::ESRCH, Errno::ECHILD
      nil
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "weather_token") do
    result = SmithIslandMcpBearer::WeatherToken.conduct
  end

  puts result.answer
end
