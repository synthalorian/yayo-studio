class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project_type, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :status
      t.string :repo_url
      t.string :website_url
      t.jsonb :config

      t.timestamps
    end
  end
end
