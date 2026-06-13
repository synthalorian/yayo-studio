require "test_helper"

class JournalEntryTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    entry = JournalEntry.new(
      title: "Test Entry",
      project: projects(:holy_lands)
    )
    assert entry.valid?
  end

  test "should require title" do
    entry = JournalEntry.new(title: "", project: projects(:holy_lands))
    assert_not entry.valid?
    assert_includes entry.errors[:title], "can't be blank"
  end

  test "should require project" do
    entry = JournalEntry.new(title: "Test")
    assert_not entry.valid?
  end

  test "should set entry_date before save if blank" do
    entry = JournalEntry.create!(title: "Test", project: projects(:holy_lands))
    assert_equal Date.current, entry.entry_date
  end

  test "should not overwrite existing entry_date" do
    past_date = Date.current - 7
    entry = JournalEntry.create!(title: "Test", project: projects(:holy_lands), entry_date: past_date)
    assert_equal past_date, entry.entry_date
  end

  test "recent scope should order by entry_date desc" do
    entries = JournalEntry.recent
    assert entries.first.entry_date >= entries.last.entry_date
  end

  test "should have rich text content" do
    entry = journal_entries(:entry_one)
    assert_respond_to entry, :content
  end

  test "should have many tags through taggings" do
    entry = journal_entries(:entry_one)
    assert_respond_to entry, :tags
  end
end
