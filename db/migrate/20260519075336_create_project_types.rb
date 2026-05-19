class CreateProjectTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :project_types do |t|
      t.string :name
      t.string :icon
      t.string :color
      t.text :description
      t.integer :position

      t.timestamps
    end
    add_index :project_types, :name, unique: true
  end
end
