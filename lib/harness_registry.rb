require "shellwords"

# frozen_string_literal: true

# Harness Registry — every AI agent/tool in existence
# Each harness defines: metadata, config schema, CLI discovery, health check
class HarnessRegistry
  Harness = Struct.new(
    :key, :name, :category, :description,
    :cli_name, :cli_paths, :endpoint_template,
    :config_schema, :discovery_command,
    :health_check_command, :website,
    keyword_init: true
  )

  CATEGORIES = {
    cli_agents: "CLI Coding Agents",
    agent_frameworks: "Agent Frameworks",
    local_inference: "Local Inference",
    mcp_protocol: "MCP Protocol",
    game_engine: "Game Engine Bridges",
    custom: "Custom/Hybrid"
  }.freeze

  class << self
    def all
      @all ||= build_registry.values
    end

    def find(key)
      build_registry[key.to_s]
    end

    def by_category(cat)
      all.select { |h| h.category == cat }
    end

    def categories
      CATEGORIES
    end

    def auto_discover!
      found = []
      all.each do |harness|
        next unless harness.cli_name

        path = find_cli(harness.cli_name, harness.cli_paths || [])
        if path
          version = detect_version(path, harness.discovery_command)
          found << { harness: harness.key, path: path, version: version, status: "connected" }
        end
      end
      found
    end

    def find_cli(name, extra_paths = [])
      escaped_name = Shellwords.escape(name)
      # Check PATH first
      path = `which #{escaped_name} 2>/dev/null`.strip
      return path unless path.empty?

      # Check common locations
      common = [
        "/usr/local/bin/#{escaped_name}",
        "/usr/bin/#{escaped_name}",
        "/home/synth/.local/bin/#{escaped_name}",
        "/home/synth/.local/share/mise/installs/*/bin/#{escaped_name}",
        *extra_paths
      ]

      common.each do |p|
        expanded = Dir.glob(p).first
        return expanded if expanded && File.executable?(expanded)
      end

      # Check mise-managed tools
      mise_path = `mise which #{escaped_name} 2>/dev/null`.strip
      return mise_path unless mise_path.empty?

      nil
    end

    def detect_version(path, discovery_cmd)
      return "?" unless path && discovery_cmd

      escaped_path = Shellwords.escape(path)
      result = `#{discovery_cmd.call(escaped_path)} 2>/dev/null`.strip
      result.empty? ? "?" : result
    rescue StandardError => e
      Rails.logger.error "Version detection failed for #{path}: #{e.message}"
      "?"
    end

    private

    def build_registry
      reg = {}

      # ===== CLI CODING AGENTS =====

      reg["claude-code"] = Harness.new(
        key: "claude-code", name: "Claude Code", category: :cli_agents,
        description: "Anthropic's official CLI coding agent — full repo read/write, autonomous task execution",
        cli_name: "claude", cli_paths: [ "/usr/sbin/claude" ],
        endpoint_template: nil,
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "#{path} --version 2>/dev/null" },
        config_schema: {
          fields: [
            { key: "api_key", label: "Anthropic API Key", type: "password", optional: true },
            { key: "max_tokens", label: "Max Tokens", type: "number", default: 8192 },
            { key: "model", label: "Model", type: "select", options: [ "claude-sonnet-4-20250514", "claude-opus-4-20250514", "claude-haiku-4-20250514" ] }
          ],
          auto_connect: true,
          launch_command: ->(config) { "claude" }
        },
        website: "https://docs.anthropic.com/en/docs/claude-code/overview"
      )

      reg["codex"] = Harness.new(
        key: "codex", name: "Codex CLI", category: :cli_agents,
        description: "OpenAI's terminal coding agent — sandboxed code execution, multi-file edits",
        cli_name: "codex",
        cli_paths: [ "/home/synth/.local/bin/codex" ],
        endpoint_template: nil,
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || head -3 #{path} | grep -oP 'VERSION|v\\d+\\.\\d+' || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "api_key", label: "OpenAI API Key", type: "password", optional: true },
            { key: "model", label: "Model", type: "select", options: [ "o4-mini", "o3", "gpt-4o" ] },
            { key: "sandbox", label: "Sandbox Mode", type: "boolean", default: true }
          ],
          auto_connect: true,
          launch_command: ->(config) { "codex" }
        },
        website: "https://github.com/openai/codex"
      )

      reg["opencode"] = Harness.new(
        key: "opencode", name: "OpenCode CLI", category: :cli_agents,
        description: "Open-source coding agent — extensible, multi-model support",
        cli_name: "opencode",
        cli_paths: [ "/home/synth/.local/bin/opencode" ],
        endpoint_template: nil,
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "provider", label: "Provider", type: "select", options: [ "openai", "anthropic", "openrouter", "local" ] },
            { key: "model", label: "Model", type: "string" },
            { key: "api_key", label: "API Key", type: "password", optional: true }
          ],
          auto_connect: true,
          launch_command: ->(config) { "opencode" }
        },
        website: "https://github.com/opencode-ai/opencode"
      )

      reg["openclaw"] = Harness.new(
        key: "openclaw", name: "OpenClaw", category: :cli_agents,
        description: "Synth's own AI agent framework — custom tools, MCP bridge, autonomous coding",
        cli_name: nil,
        cli_paths: [ "/home/synth/projects/openclaw" ],
        endpoint_template: "http://localhost:%{port}",
        discovery_command: ->(path) { "test -d #{path} && echo 'repository' || echo 'missing'" },
        health_check_command: ->(path) { "ls #{path}/ 2>/dev/null | head -1" },
        config_schema: {
          fields: [
            { key: "repo_path", label: "Repository Path", type: "path", default: "/home/synth/projects/openclaw" },
            { key: "port", label: "API Port", type: "number", default: 8080 },
            { key: "mode", label: "Mode", type: "select", options: [ "server", "cli", "hybrid" ] }
          ],
          auto_connect: false,
          launch_command: ->(config) { "cd #{config['repo_path']} && ./scripts/start.sh" }
        },
        website: nil
      )

      reg["claw-code"] = Harness.new(
        key: "claw-code", name: "Claw Code", category: :cli_agents,
        description: "Synth's lightweight coding agent — Gemini-powered, focused on rapid development",
        cli_name: nil,
        cli_paths: [ "/home/synth/projects/claw-code-gemini-setup-guide" ],
        endpoint_template: "http://localhost:%{port}",
        discovery_command: ->(path) { "test -d #{path} && echo 'repository' || echo 'missing'" },
        health_check_command: ->(path) { "ls #{path}/ 2>/dev/null | head -3" },
        config_schema: {
          fields: [
            { key: "repo_path", label: "Repository Path", type: "path", default: "/home/synth/projects/claw-code-gemini-setup-guide" },
            { key: "gemini_api_key", label: "Gemini API Key", type: "password", optional: true },
            { key: "port", label: "API Port", type: "number", default: 8081 }
          ],
          auto_connect: false,
          launch_command: ->(config) { "cd #{config['repo_path']} && python main.py" }
        },
        website: nil
      )

      reg["aider"] = Harness.new(
        key: "aider", name: "Aider", category: :cli_agents,
        description: "AI pair programming in terminal — git-aware, multi-model, architect mode",
        cli_name: "aider",
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "model", label: "Model", type: "string", default: "claude-sonnet-4-20250514" },
            { key: "api_key", label: "API Key", type: "password", optional: true },
            { key: "architect", label: "Architect Mode", type: "boolean", default: false },
            { key: "auto_commits", label: "Auto Commits", type: "boolean", default: true }
          ],
          auto_connect: true,
          launch_command: ->(config) { "aider --model #{config['model']}" }
        },
        website: "https://aider.chat"
      )

      reg["copilot"] = Harness.new(
        key: "copilot", name: "GitHub Copilot CLI", category: :cli_agents,
        description: "GitHub's AI coding assistant — explain, suggest, translate in terminal",
        cli_name: "copilot",
        cli_paths: [ "/home/synth/.local/bin/copilot" ],
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "auth_token", label: "Auth Token", type: "password", optional: true },
            { key: "model", label: "Model", type: "select", options: [ "claude-sonnet", "gpt-4o", "gemini" ] }
          ],
          auto_connect: true,
          launch_command: ->(config) { "copilot" }
        },
        website: "https://github.com/github/gh-copilot"
      )

      reg["goose"] = Harness.new(
        key: "goose", name: "Goose", category: :cli_agents,
        description: "Block's open-source AI coding agent — autonomous, extensible toolkit",
        cli_name: "goose",
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "provider", label: "Provider", type: "select", options: [ "openai", "anthropic", "openrouter" ] },
            { key: "model", label: "Model", type: "string", default: "claude-sonnet-4-20250514" },
            { key: "api_key", label: "API Key", type: "password", optional: true }
          ],
          auto_connect: true,
          launch_command: ->(config) { "goose" }
        },
        website: "https://github.com/block/goose"
      )

      reg["mentat"] = Harness.new(
        key: "mentat", name: "Mentat", category: :cli_agents,
        description: "AI coding assistant that understands your full codebase",
        cli_name: "mentat",
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "api_key", label: "API Key", type: "password" },
            { key: "model", label: "Model", type: "string", default: "gpt-4" }
          ],
          auto_connect: true,
          launch_command: ->(config) { "mentat" }
        },
        website: "https://mentat.ai"
      )

      # ===== AGENT FRAMEWORKS =====

      reg["hermes-agent"] = Harness.new(
        key: "hermes-agent", name: "Hermes Agent", category: :agent_frameworks,
        description: "Nous Research's autonomous agent — MCP-native, multi-provider, Discord-integrated",
        cli_name: "hermes",
        cli_paths: [ "/home/synth/.local/bin/hermes" ],
        endpoint_template: nil,
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "profile", label: "Profile", type: "select", options: [ "default", "dev", "wingman" ] },
            { key: "provider", label: "Provider", type: "select", options: [ "anthropic", "openai", "nous", "xai", "deepseek", "openrouter" ] },
            { key: "model", label: "Model", type: "string", default: "claude-sonnet-4-20250514" },
            { key: "mcp_enabled", label: "MCP Servers", type: "boolean", default: true }
          ],
          auto_connect: true,
          launch_command: ->(config) { "hermes run" }
        },
        website: "https://hermes-agent.nousresearch.com"
      )

      reg["hermes-wingman"] = Harness.new(
        key: "hermes-wingman", name: "Hermes Wingman", category: :agent_frameworks,
        description: "Flutter desktop frontend for Hermes Agent — chat UI, theme engine, agent spawning",
        cli_name: nil,
        cli_paths: [ "/home/synth/projects/hermes_wingman" ],
        endpoint_template: nil,
        discovery_command: ->(path) { "test -d #{path} && echo 'flutter_project' || echo 'missing'" },
        health_check_command: ->(path) { "ls #{path}/lib/ 2>/dev/null | head -3" },
        config_schema: {
          fields: [
            { key: "repo_path", label: "Repository Path", type: "path", default: "/home/synth/projects/hermes_wingman" },
            { key: "hermes_profile", label: "Hermes Profile", type: "string", default: "wingman" },
            { key: "port", label: "Dev Server Port", type: "number", default: 3001 }
          ],
          auto_connect: false,
          launch_command: ->(config) { "cd #{config['repo_path']} && flutter run -d linux" }
        },
        website: nil
      )

      reg["open-interpreter"] = Harness.new(
        key: "open-interpreter", name: "Open Interpreter", category: :agent_frameworks,
        description: "Natural language computer control — code execution, file management, web browsing",
        cli_name: "interpreter",
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "model", label: "Model", type: "string", default: "gpt-4" },
            { key: "api_key", label: "API Key", type: "password", optional: true },
            { key: "auto_run", label: "Auto Run Mode", type: "boolean", default: false }
          ],
          auto_connect: true,
          launch_command: ->(config) { "interpreter" }
        },
        website: "https://openinterpreter.com"
      )

      # ===== LOCAL INFERENCE =====

      reg["ollama"] = Harness.new(
        key: "ollama", name: "Ollama", category: :local_inference,
        description: "Local LLM runner — pull and run models like Llama, Mistral, Gemma on your hardware",
        cli_name: "ollama",
        cli_paths: [ "/usr/local/bin/ollama" ],
        endpoint_template: "http://localhost:11434",
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "curl -s http://localhost:11434/api/tags > /dev/null 2>&1 && echo 'running' || echo 'not running'" },
        config_schema: {
          fields: [
            { key: "host", label: "Host", type: "string", default: "http://localhost:11434" },
            { key: "default_model", label: "Default Model", type: "select", options: [ "llama3.1", "qwen2.5", "mistral", "gemma3", "codestral" ] },
            { key: "keep_alive", label: "Keep Alive (min)", type: "number", default: 5 }
          ],
          auto_connect: true,
          launch_command: ->(config) { "ollama serve" }
        },
        website: "https://ollama.com"
      )

      reg["llama-cpp"] = Harness.new(
        key: "llama-cpp", name: "llama.cpp", category: :local_inference,
        description: "High-performance local GGUF inference — optimized for your RX 9070 XT GPU",
        cli_name: nil,
        cli_paths: [ "/home/synth/llama.cpp/build/bin/llama-server" ],
        endpoint_template: "http://localhost:%{port}",
        discovery_command: ->(path) { "test -x #{path} && echo 'compiled' || echo 'missing'" },
        health_check_command: ->(path) { "curl -s http://localhost:8080/health 2>/dev/null && echo 'running' || echo 'not running'" },
        config_schema: {
          fields: [
            { key: "server_path", label: "Server Binary", type: "path", default: "/home/synth/llama.cpp/build/bin/llama-server" },
            { key: "port", label: "Port", type: "number", default: 8080 },
            { key: "model_path", label: "Model Path", type: "path" },
            { key: "ngl", label: "GPU Layers", type: "number", default: 80 },
            { key: "vulkan", label: "Vulkan Acceleration", type: "boolean", default: true }
          ],
          auto_connect: false,
          launch_command: ->(config) { "#{config['server_path']} -m #{config['model_path']} --port #{config['port']} --ngl #{config['ngl']}" }
        },
        website: "https://github.com/ggml-org/llama.cpp"
      )

      reg["vllm"] = Harness.new(
        key: "vllm", name: "vLLM", category: :local_inference,
        description: "High-throughput LLM serving with PagedAttention — ideal for production inference",
        cli_name: nil,
        discovery_command: nil,
        health_check_command: ->(path) { "python3 -c 'import vllm; print(vllm.__version__)' 2>/dev/null || echo 'not installed'" },
        config_schema: {
          fields: [
            { key: "model", label: "Model Name", type: "string" },
            { key: "port", label: "API Port", type: "number", default: 8000 },
            { key: "gpu_memory_utilization", label: "GPU Memory %", type: "number", default: 0.9 },
            { key: "max_model_len", label: "Max Context Length", type: "number", default: 32768 }
          ],
          auto_connect: false,
          launch_command: ->(config) { "python3 -m vllm.entrypoints.openai.api_server --model #{config['model']} --port #{config['port']}" }
        },
        website: "https://github.com/vllm-project/vllm"
      )

      # ===== MCP PROTOCOL =====

      reg["mcp-bridge"] = Harness.new(
        key: "mcp-bridge", name: "MCP Bridge", category: :mcp_protocol,
        description: "Model Context Protocol — universal bridge connecting AI agents to tools and data sources",
        cli_name: "mcporter",
        cli_paths: [ "/home/synth/.local/bin/mcporter" ],
        endpoint_template: nil,
        discovery_command: ->(path) { "#{path} --version 2>/dev/null || echo '?'" },
        health_check_command: ->(path) { "test -x #{path} && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "servers", label: "MCP Servers (comma-separated)", type: "string", default: "filesystem,github" },
            { key: "transport", label: "Transport", type: "select", options: [ "stdio", "sse", "streamable-http" ] },
            { key: "port", label: "Bridge Port", type: "number", default: 8090 }
          ],
          auto_connect: true,
          launch_command: ->(config) { "mcporter --transport #{config['transport']} --port #{config['port']}" }
        },
        website: "https://modelcontextprotocol.io"
      )

      # ===== GAME ENGINE BRIDGES =====

      reg["unity-mcp"] = Harness.new(
        key: "unity-mcp", name: "Unity MCP", category: :game_engine,
        description: "MCP bridge for Unity game engine — AI-controlled scene editing, C# scripting, asset management",
        cli_name: nil,
        cli_paths: [ "/home/synth/projects/unity-mcp" ],
        endpoint_template: "http://localhost:%{port}",
        discovery_command: ->(path) { "test -d #{path} && echo 'repository' || echo 'missing'" },
        health_check_command: ->(path) { "test -f #{path}/package.json && echo 'ok' || echo 'missing'" },
        config_schema: {
          fields: [
            { key: "repo_path", label: "Repository Path", type: "path", default: "/home/synth/projects/unity-mcp" },
            { key: "port", label: "Bridge Port", type: "number", default: 8765 },
            { key: "unity_project", label: "Unity Project Path", type: "path", default: "/home/synth/projects/holy-lands" }
          ],
          auto_connect: false,
          launch_command: ->(config) { "cd #{config['repo_path']} && npm start" }
        },
        website: nil
      )

      reg["unreal-mcp"] = Harness.new(
        key: "unreal-mcp", name: "Unreal Engine MCP", category: :game_engine,
        description: "MCP bridge for Unreal Engine — AI-controlled Blueprint editing, C++ compilation, level design",
        cli_name: nil,
        cli_paths: [ "/home/synth/projects/Unreal_mcp" ],
        endpoint_template: "http://localhost:%{port}",
        discovery_command: ->(path) { "test -d #{path} && echo 'repository' || echo 'missing'" },
        health_check_command: ->(path) { "ls #{path}/ 2>/dev/null | head -3" },
        config_schema: {
          fields: [
            { key: "repo_path", label: "Repository Path", type: "path", default: "/home/synth/projects/Unreal_mcp" },
            { key: "port", label: "Bridge Port", type: "number", default: 8766 },
            { key: "unreal_project", label: "Unreal Project Path", type: "path", default: "/home/synth/projects/synthocalypse" }
          ],
          auto_connect: false,
          launch_command: ->(config) { "cd #{config['repo_path']} && python server.py" }
        },
        website: nil
      )

      reg["godot-mcp"] = Harness.new(
        key: "godot-mcp", name: "Godot MCP", category: :game_engine,
        description: "MCP bridge for Godot Engine — AI-controlled GDScript, scene tree, asset pipeline",
        cli_name: nil,
        cli_paths: [ "/home/synth/projects/Godot-MCP", "/home/synth/projects/godot-ai-bridge" ],
        endpoint_template: "http://localhost:%{port}",
        discovery_command: ->(path) { "test -d #{path} && echo 'repository' || echo 'missing'" },
        health_check_command: ->(path) { "ls #{path}/ 2>/dev/null | head -3" },
        config_schema: {
          fields: [
            { key: "repo_path", label: "Repository Path", type: "path", default: "/home/synth/projects/Godot-MCP" },
            { key: "port", label: "Bridge Port", type: "number", default: 8767 },
            { key: "godot_project", label: "Godot Project Path", type: "path", default: "/home/synth/projects/Blood-Legacy" }
          ],
          auto_connect: false,
          launch_command: ->(config) { "cd #{config['repo_path']} && python bridge.py" }
        },
        website: nil
      )

      # ===== CUSTOM / HYBRID =====

      reg["custom-endpoint"] = Harness.new(
        key: "custom-endpoint", name: "Custom API Endpoint", category: :custom,
        description: "Any OpenAI-compatible API endpoint — local or remote, any provider, any model",
        cli_name: nil,
        discovery_command: nil,
        health_check_command: ->(path) { "curl -s #{ENV['ENDPOINT_URL'] || 'http://localhost:8000'}/v1/models > /dev/null 2>&1 && echo 'ok' || echo 'unreachable'" },
        config_schema: {
          fields: [
            { key: "endpoint_url", label: "Endpoint URL", type: "string", required: true },
            { key: "api_key", label: "API Key", type: "password", optional: true },
            { key: "model", label: "Model Name", type: "string" },
            { key: "provider", label: "Provider Label", type: "string", default: "custom" }
          ],
          auto_connect: false,
          launch_command: nil
        },
        website: nil
      )

      reg["openai"] = Harness.new(
        key: "openai", name: "OpenAI API", category: :custom,
        description: "OpenAI's API — GPT-4o, o3, o4-mini models for chat, code, and reasoning",
        cli_name: nil,
        discovery_command: nil,
        health_check_command: ->(path) { "curl -s https://api.openai.com/v1/models -H 'Authorization: Bearer #{ENV['OPENAI_API_KEY']&.slice(0, 10)}...' > /dev/null 2>&1 && echo 'authorized' || echo 'no key'" },
        config_schema: {
          fields: [
            { key: "api_key", label: "API Key", type: "password" },
            { key: "default_model", label: "Default Model", type: "select", options: [ "o4-mini", "o3", "gpt-4o", "gpt-4o-mini", "o1" ] },
            { key: "organization", label: "Organization ID", type: "string", optional: true }
          ],
          auto_connect: false,
          launch_command: nil
        },
        website: "https://platform.openai.com"
      )

      reg["anthropic"] = Harness.new(
        key: "anthropic", name: "Anthropic API", category: :custom,
        description: "Anthropic's API — Claude Sonnet 4, Opus 4 models for reasoning and coding",
        cli_name: nil,
        discovery_command: nil,
        health_check_command: ->(path) { "curl -s https://api.anthropic.com/v1/messages --max-time 5 > /dev/null 2>&1 && echo 'reachable' || echo 'unreachable'" },
        config_schema: {
          fields: [
            { key: "api_key", label: "API Key", type: "password" },
            { key: "default_model", label: "Default Model", type: "select", options: [ "claude-sonnet-4-20250514", "claude-opus-4-20250514", "claude-haiku-4-20250514" ] }
          ],
          auto_connect: false,
          launch_command: nil
        },
        website: "https://console.anthropic.com"
      )

      reg
    end
  end
end
