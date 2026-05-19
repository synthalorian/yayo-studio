class CreateThemes < ActiveRecord::Migration[8.1]
  def change
    create_table :themes do |t|
      t.string :name
      t.boolean :is_system
      t.jsonb :colors

      t.timestamps
    end
    add_index :themes, :name, unique: true
  end
end
