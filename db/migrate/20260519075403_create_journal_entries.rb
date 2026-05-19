class CreateJournalEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_entries do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.date :entry_date

      t.timestamps
    end
  end
end
