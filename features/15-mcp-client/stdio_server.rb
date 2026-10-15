#!/usr/bin/env ruby
# frozen_string_literal: true

# Protocol-only MCP fixture. Scenario folders pass a JSON profile with the
# tools, resources, and prompts for that job. This file has no station,
# boat, or cabinet names.

require "base64"
require "json"
require "stringio"
require "uri"

$stdout.sync = true
$stderr.sync = true

SUBSCRIPTION_ID = "io.modelcontextprotocol/subscriptionId"
TASKS = "io.modelcontextprotocol/tasks"
LISTS = {
  "notifications/tools/list_changed" => "toolsListChanged",
  "notifications/prompts/list_changed" => "promptsListChanged",
  "notifications/resources/list_changed" => "resourcesListChanged"
}.freeze

profile_path = ARGV.find { |argument| !argument.start_with?("-") }
PROFILE = JSON.parse(File.read(profile_path))
HTTP_MODE = ARGV.include?("--http")
HTTP_PORT = Integer(ENV.fetch("MCP_HTTP_PORT", "18765"))
ACCEPTED_TOKENS = ENV.fetch("MCP_BEARER_TOKEN", "").split(",").map(&:strip).reject(&:empty?)
OAUTH_CLIENT_ID = ENV["MCP_CLIENT_ID"]
OAUTH_CLIENT_SECRET = ENV["MCP_CLIENT_SECRET"]
OAUTH_ACCESS_TOKEN = ENV["MCP_OAUTH_ACCESS_TOKEN"]

def tools_from_profile
  PROFILE.fetch("tools", []).map { |tool| symbolize_tool(tool) }
end

def symbolize_tool(tool)
  {
    name: tool.fetch("name"),
    description: tool["description"],
    inputSchema: tool["inputSchema"] || { "type" => "object" },
    annotations: tool["annotations"] || { "readOnlyHint" => true }
  }
end

def clone_tools
  tools_from_profile
end

tools = clone_tools
added_specs = {}
subscriptions = {}
tasks = {}

def capabilities
  { "tools" => { "listChanged" => true }, "prompts" => { "listChanged" => true },
    "resources" => { "listChanged" => true, "subscribe" => true } }
end

def notify(method, params)
  emit({ "jsonrpc" => "2.0", "method" => method, "params" => params })
end

def emit(message)
  $stdout.puts(JSON.generate(message))
end

def reply(id, result: nil, error: nil)
  emit({ "jsonrpc" => "2.0", "id" => id, "result" => result, "error" => error }.compact)
end

def interpolate(text, arguments)
  text.to_s.gsub(/\{\{(\w+)\}\}/) { arguments[$1].to_s }
end

def resource_listing
  PROFILE.fetch("resources", []).map do |resource|
    { "uri" => resource["uri"], "name" => resource["name"], "mimeType" => resource["mimeType"] }
  end
end

def read_resource(uri)
  resource = PROFILE.fetch("resources", []).find { |entry| entry["uri"] == uri }
  return { "contents" => [{ "uri" => uri, "mimeType" => "text/plain", "text" => "No card for #{uri}" }] } unless resource

  contents = { "uri" => uri, "name" => resource["name"], "mimeType" => resource["mimeType"] }
  contents["text"] = resource["text"] if resource["text"]
  contents["blob"] = resource["blob"] if resource["blob"]
  { "contents" => [contents] }
end

def prompt_listing
  PROFILE.fetch("prompts", []).map do |prompt|
    { "name" => prompt["name"], "description" => prompt["description"], "arguments" => prompt["arguments"] }
  end
end

def get_prompt(name, arguments)
  prompt = PROFILE.fetch("prompts", []).find { |entry| entry["name"] == name }
  raise ArgumentError, "Unknown prompt: #{name}" unless prompt

  messages = prompt.fetch("messages").map do |message|
    { "role" => message["role"], "content" => { "type" => "text", "text" => interpolate(message["text"], arguments) } }
  end
  { "description" => prompt["description"], "messages" => messages }
end

def text_result(text)
  { "content" => [{ "type" => "text", "text" => text.to_s }] }
end

def elicit_result(key, spec)
  schema = {
    "type" => "object",
    "required" => spec.fetch("required", []),
    "properties" => spec.fetch("fields")
  }
  {
    "resultType" => "input_required",
    "inputRequests" => {
      key => {
        "method" => "elicitation/create",
        "params" => { "mode" => "form", "message" => spec["message"], "requestedSchema" => schema }
      }
    },
    "requestState" => "#{key}-state"
  }
end

def task_state(id, status, **fields)
  {
    "taskId" => id,
    "status" => status,
    "createdAt" => "2026-10-15T11:00:00Z",
    "lastUpdatedAt" => "2026-10-15T11:00:00Z",
    "ttlMs" => 60_000,
    "pollIntervalMs" => 10
  }.merge(fields)
end

def wants?(filter, method, params)
  return Array(filter["resourceSubscriptions"]).include?(params["uri"]) if method == "notifications/resources/updated"
  return Array(filter["taskIds"]).include?(params["taskId"]) if method == "notifications/tasks"

  filter[LISTS.fetch(method)] == true
end

def announce(subscriptions, method, params = {})
  subscriptions.each do |id, filter|
    next unless wants?(filter, method, params)

    notify(method, params.merge("_meta" => { SUBSCRIPTION_ID => id }))
  end
end

def listen(subscriptions, id, filter)
  honored = filter.dup
  notify("notifications/subscriptions/acknowledged",
         "_meta" => { SUBSCRIPTION_ID => id }, "notifications" => honored)
  subscriptions[id] = honored
end

def fill_result(spec, arguments)
  interpolate(spec.fetch("text"), arguments)
end

def call_named_tool(tools, added_specs, params, subscriptions, tasks)
  name = params["name"]
  arguments = params.fetch("arguments", {})
  spec = PROFILE.fetch("tools", []).find { |tool| tool["name"] == name } || added_specs[name]
  raise ArgumentError, "Unknown tool: #{name}" unless spec
  raise ArgumentError, "Unknown tool: #{name}" unless tools.any? { |tool| tool[:name] == name }

  if spec["elicit"]
    answer = params.dig("inputResponses", spec["elicit"])
    form = PROFILE.fetch("elicit").fetch(spec["elicit"])
    unless answer && params["requestState"] == "#{spec['elicit']}-state"
      return elicit_result(spec["elicit"], form)
    end
    return text_result("Call cancelled") unless answer["action"] == "accept"

    chosen = answer.dig("content", form.fetch("choice_field", "choice"))
    return text_result(interpolate(form.fetch("results").fetch(chosen.to_s), arguments.merge(form["choice_field"] => chosen)))
  end

  if spec["task"]
    task_spec = PROFILE.fetch("tasks").fetch(spec["task"])
    id = "task-#{tasks.size + 1}"
    tasks[id] = { "spec" => task_spec, "polls" => 0 }
    return task_state(id, "working", "statusMessage" => task_spec.fetch("working").first, "resultType" => "task")
  end

  if spec["add_tool"]
    added = symbolize_tool(spec["add_tool"])
    added_specs[added[:name]] = spec["add_tool"]
    tools << added unless tools.any? { |tool| tool[:name] == added[:name] }
    announce(subscriptions, "notifications/tools/list_changed")
  end

  if spec["update_resource"]
    announce(subscriptions, "notifications/resources/updated", "uri" => spec["update_resource"])
  end

  text_result(fill_result(spec, arguments))
end

def poll_task(task, id)
  task["polls"] += 1
  spec = task["spec"]
  working = spec.fetch("working")
  return task_state(id, "working", "statusMessage" => working[task["polls"] - 1] || working.last) if task["polls"] < working.size

  task_state(id, "completed", "result" => text_result(spec.fetch("text")))
end

def handle(message, tools, added_specs, subscriptions, tasks)
  id = message["id"]
  params = message.fetch("params", {})
  method = message["method"]

  case method
  when "server/discover"
    reply(id, result: {
            "resultType" => "complete",
            "supportedVersions" => ["2026-07-28"],
            "capabilities" => capabilities,
            "instructions" => PROFILE["instructions"],
            "_meta" => { "io.modelcontextprotocol/serverInfo" => { "name" => PROFILE.fetch("name", "desk"), "version" => "1.0.0" } }
          })
  when "initialize"
    reply(id, result: { "protocolVersion" => "2025-06-18", "capabilities" => capabilities,
                        "serverInfo" => { "name" => PROFILE.fetch("name", "desk"), "version" => "1.0.0" } })
  when "notifications/initialized"
    nil
  when "ping"
    reply(id, result: {})
  when "tools/list"
    reply(id, result: { "tools" => tools })
  when "tools/call"
    reply(id, result: call_named_tool(tools, added_specs, params, subscriptions, tasks))
  when "resources/list"
    reply(id, result: { "resources" => resource_listing })
  when "resources/read"
    reply(id, result: read_resource(params["uri"]))
  when "resources/templates/list"
    reply(id, result: { "resourceTemplates" => PROFILE.fetch("resourceTemplates", []) })
  when "prompts/list"
    reply(id, result: { "prompts" => prompt_listing })
  when "prompts/get"
    reply(id, result: get_prompt(params["name"], params.fetch("arguments", {})))
  when "subscriptions/listen"
    listen(subscriptions, id, params.fetch("notifications", {}))
  when "tasks/get"
    task = tasks[params["taskId"]]
    if task.nil?
      reply(id, error: { "code" => -32_602, "message" => "Task not found" })
    else
      reply(id, result: poll_task(task, params["taskId"]).merge("resultType" => "complete"))
    end
  when "tasks/cancel"
    reply(id, result: { "resultType" => "complete" })
  when "notifications/cancelled"
    subscriptions.delete(params["requestId"])
  else
    reply(id, error: { "code" => -32_601, "message" => "Method not found" }) if id
  end
end

def authorized?(header)
  return true if ACCEPTED_TOKENS.empty? && OAUTH_ACCESS_TOKEN.nil?

  token = header.to_s.delete_prefix("Bearer ").strip
  ACCEPTED_TOKENS.include?(token) || token == OAUTH_ACCESS_TOKEN
end

def origin
  "http://127.0.0.1:#{HTTP_PORT}"
end

def json_response(response, status, body, extra_headers = {})
  payload = JSON.generate(body)
  response.status = status
  response["Content-Type"] = "application/json"
  extra_headers.each { |name, value| response[name] = value }
  response.body = payload
end

if HTTP_MODE
  require "webrick"

  logger = WEBrick::Log.new(File::NULL)
  server = WEBrick::HTTPServer.new(Port: HTTP_PORT, Logger: logger, AccessLog: [])
  trap("INT") { server.shutdown }
  trap("TERM") { server.shutdown }

  server.mount_proc "/.well-known/oauth-protected-resource" do |_request, response|
    json_response(response, 200, {
                    "resource" => "#{origin}/mcp",
                    "authorization_servers" => [origin]
                  })
  end

  server.mount_proc "/.well-known/oauth-authorization-server" do |_request, response|
    json_response(response, 200, {
                    "issuer" => origin,
                    "token_endpoint" => "#{origin}/token",
                    "token_endpoint_auth_methods_supported" => ["client_secret_basic"]
                  })
  end

  server.mount_proc "/token" do |request, response|
    header = request["Authorization"].to_s
    expected = Base64.strict_encode64("#{URI.encode_www_form_component(OAUTH_CLIENT_ID)}:#{URI.encode_www_form_component(OAUTH_CLIENT_SECRET)}")
    unless header == "Basic #{expected}"
      json_response(response, 401, { "error" => "invalid_client" })
      next
    end

    form = URI.decode_www_form(request.body.to_s).to_h
    unless form["grant_type"] == "client_credentials"
      json_response(response, 400, { "error" => "unsupported_grant_type" })
      next
    end

    json_response(response, 200, {
                    "access_token" => OAUTH_ACCESS_TOKEN,
                    "token_type" => "Bearer",
                    "expires_in" => 3600
                  })
  end

  server.mount_proc "/mcp" do |request, response|
    unless authorized?(request["Authorization"])
      json_response(
        response,
        401,
        { "error" => "invalid_token" },
        "WWW-Authenticate" => %(Bearer realm="mcp", resource_metadata="#{origin}/.well-known/oauth-protected-resource")
      )
      next
    end

    message = JSON.parse(request.body)
    captured = []
    original = $stdout
    $stdout = captured_io = StringIO.new
    begin
      handle(message, tools, added_specs, subscriptions, tasks)
    ensure
      $stdout = original
    end
    lines = captured_io.string.lines.map { |line| JSON.parse(line) }
    answer = lines.reverse.find { |line| line["id"] == message["id"] && !line.key?("method") }
    json_response(response, 200, answer)
  end

  server.start
else
  $stdin.each_line do |line|
    handle(JSON.parse(line), tools, added_specs, subscriptions, tasks)
  end
end
