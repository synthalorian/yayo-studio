class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.string :file_path
      t.string :asset_type
      t.jsonb :metadata

      t.timestamps
    end
  end
end
