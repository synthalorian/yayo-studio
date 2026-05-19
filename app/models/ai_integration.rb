class AiIntegration < ApplicationRecord
  belongs_to :project

  validates :name, presence: true
  validates :provider, presence: true

  scope :enabled, -> { where(enabled: true) }
  scope :connected, -> { where(status: "connected") }
  scope :by_harness, -> { order(harness_type: :asc, name: :asc) }

  PROVIDERS = %w[hermes openai anthropic openrouter local custom claude codex aider copilot goose mentat ollama llama open interpreter mcp unity unreal godot openclaw claw].freeze
  validates :provider, inclusion: { in: PROVIDERS, allow_blank: true }

  before_save :set_defaults
  after_create_commit :auto_discover_harness

  def harness_definition
    HarnessRegistry.find(harness_type)
  end

  def display_name
    harness_definition&.name || name
  end

  def display_category
    return "Unknown" unless harness_definition
    HarnessRegistry.categories[harness_definition.category] || harness_definition.category.to_s.titleize
  end

  def health_status
    return "unknown" unless status
    case status
    when "connected" then "connected"
    when "disconnected" then "disconnected"
    when "error" then "error"
    else "unknown"
    end
  end

  def check_health!
    harness = harness_definition
    unless harness&.health_check_command
      update!(status: "unknown", last_health_check: Time.current)
      return "unknown"
    end

    begin
      # Try CLI-based health check
      cli_path = HarnessRegistry.find_cli(harness.cli_name, harness.cli_paths || [])
      if cli_path
        result = `#{harness.health_check_command.call(cli_path)} 2>/dev/null`.strip
        connected = result.downcase.include?("ok") || result.downcase.include?("running")
        new_status = connected ? "connected" : "disconnected"
        update!(status: new_status, last_health_check: Time.current)
        return new_status
      end

      # Try endpoint-based health check
      if endpoint_url.present?
        result = `curl -s -o /dev/null -w "%{http_code}" --max-time 3 #{endpoint_url} 2>/dev/null`.strip
        connected = result.to_i.between?(200, 399)
        new_status = connected ? "connected" : "disconnected"
        update!(status: new_status, last_health_check: Time.current)
        return new_status
      end

      update!(status: "disconnected", last_health_check: Time.current)
      "disconnected"
    rescue => e
      update!(status: "error", last_health_check: Time.current)
      "error"
    end
  end

  def launch_command
    harness = harness_definition
    return nil unless harness&.config_schema&.dig(:launch_command)

    harness.config_schema[:launch_command].call(config || {})
  end

  private

  def set_defaults
    self.status ||= "unknown"
    self.harness_type ||= provider
  end

  def auto_discover_harness
    harness = harness_definition
    return unless harness

    # Try to find the CLI
    cli_path = HarnessRegistry.find_cli(harness.cli_name, harness.cli_paths || [])
    if cli_path
      update_column(:config, (config || {}).merge("cli_path" => cli_path))
      check_health!
    end
  end
end
