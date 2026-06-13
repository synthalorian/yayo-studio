class AddMissingIndexesAndConstraints < ActiveRecord::Migration[8.1]
  def change
    # Add missing indexes for performance
    add_index :journal_entries, :entry_date, name: "index_journal_entries_on_entry_date"
    add_index :assets, :asset_type, name: "index_assets_on_asset_type"
    add_index :projects, :status, name: "index_projects_on_status"
    add_index :ai_integrations, :enabled, name: "index_ai_integrations_on_enabled"
    add_index :ai_integrations, :provider, name: "index_ai_integrations_on_provider"
    add_index :ai_integrations, [ :project_id, :harness_type ], name: "index_ai_integrations_on_project_id_and_harness_type"
    add_index :taggings, [ :taggable_type, :taggable_id, :tag_id ], unique: true, name: "index_taggings_uniqueness"

    # Add null constraints to critical columns
    change_column_null :users, :name, false
    change_column_null :projects, :name, false
    change_column_null :journal_entries, :title, false
    change_column_null :assets, :name, false
    change_column_null :ai_integrations, :name, false
    change_column_null :tags, :name, false
    change_column_null :project_types, :name, false

    # Add default values
    change_column_default :projects, :status, from: nil, to: "planning"
    change_column_default :journal_entries, :entry_date, from: nil, to: -> { "CURRENT_DATE" }
  end
end
