require "open3"
require "shellwords"
require "net/http"

class AiIntegration < ApplicationRecord
  belongs_to :project

  validates :name, presence: true, length: { maximum: 255 }
  validates :provider, presence: true, length: { maximum: 100 }
  validates :endpoint_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL", allow_blank: true }
  validates :harness_type, length: { maximum: 100 }, allow_blank: true
  validates :status, inclusion: { in: %w[connected disconnected error unknown], allow_blank: true }

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
        cmd = harness.health_check_command.call(Shellwords.escape(cli_path))
        result, _status = Open3.capture2(cmd)
        result = result.strip
        connected = result.downcase.include?("ok") || result.downcase.include?("running")
        new_status = connected ? "connected" : "disconnected"
        update!(status: new_status, last_health_check: Time.current)
        return new_status
      end

      # Try endpoint-based health check
      if endpoint_url.present?
        uri = URI.parse(endpoint_url)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 3, open_timeout: 3) do |http|
          request = Net::HTTP::Get.new(uri)
          http.request(request)
        end
        connected = response.code.to_i.between?(200, 399)
        new_status = connected ? "connected" : "disconnected"
        update!(status: new_status, last_health_check: Time.current)
        return new_status
      end

      update!(status: "disconnected", last_health_check: Time.current)
      "disconnected"
    rescue URI::InvalidURIError, Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED => e
      update!(status: "error", last_health_check: Time.current)
      "error"
    rescue StandardError => e
      Rails.logger.error "Health check failed for #{name}: #{e.message}"
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
