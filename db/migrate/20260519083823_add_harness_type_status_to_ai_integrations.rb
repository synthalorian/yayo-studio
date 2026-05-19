class AddHarnessTypeStatusToAiIntegrations < ActiveRecord::Migration[8.1]
  def change
    add_column :ai_integrations, :harness_type, :string
    add_column :ai_integrations, :status, :string, default: "unknown"
    add_column :ai_integrations, :last_health_check, :datetime
    add_column :ai_integrations, :endpoint_url, :string

    add_index :ai_integrations, :harness_type
    add_index :ai_integrations, :status
  end
end
