require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    tag = Tag.new(name: "new-tag")
    assert tag.valid?
  end

  test "should require name" do
    tag = Tag.new(name: "")
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    existing = tags(:tag_one)
    tag = Tag.new(name: existing.name)
    assert_not tag.valid?
    assert_includes tag.errors[:name], "has already been taken"
  end

  test "alphabetical scope should order by name" do
    tags = Tag.alphabetical
    assert tags.first.name <= tags.last.name
  end
end
