require "test_helper"

class ProjectTypeTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    project_type = ProjectType.new(name: "New Type")
    assert project_type.valid?
  end

  test "should require name" do
    project_type = ProjectType.new(name: "")
    assert_not project_type.valid?
    assert_includes project_type.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    existing = project_types(:game)
    project_type = ProjectType.new(name: existing.name)
    assert_not project_type.valid?
    assert_includes project_type.errors[:name], "has already been taken"
  end

  test "should validate position as integer" do
    project_type = project_types(:game)
    project_type.position = "not-a-number"
    assert_not project_type.valid?
  end

  test "ordered scope should order by position and name" do
    types = ProjectType.ordered
    assert types.first.position <= types.last.position
  end

  test "default_icon should return correct icon" do
    project_type = project_types(:game)
    assert_equal "🎮", project_type.default_icon
  end

  test "default_icon should return fallback for unknown type" do
    project_type = ProjectType.new(name: "Unknown")
    assert_equal "📁", project_type.default_icon
  end
end
