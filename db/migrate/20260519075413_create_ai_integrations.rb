class CreateAiIntegrations < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_integrations do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.string :provider
      t.jsonb :config
      t.boolean :enabled

      t.timestamps
    end
  end
end
