require "test_helper"

class ThemeTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    theme = Theme.new(
      name: "Custom Theme",
      colors: { "background" => "#000000" }
    )
    assert theme.valid?
  end

  test "should require name" do
    theme = Theme.new(name: "", colors: { "background" => "#000000" })
    assert_not theme.valid?
    assert_includes theme.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    existing = themes(:synthwave)
    theme = Theme.new(name: existing.name, colors: { "background" => "#000000" })
    assert_not theme.valid?
    assert_includes theme.errors[:name], "has already been taken"
  end

  test "should require colors" do
    theme = Theme.new(name: "Test")
    assert_not theme.valid?
    assert_includes theme.errors[:colors], "can't be blank"
  end

  test "system scope should return system themes" do
    system = Theme.system
    assert_includes system, themes(:synthwave)
    assert_includes system, themes(:dark)
  end

  test "custom scope should return custom themes" do
    custom = Theme.custom
    assert_empty custom
  end

  test "seed_system_themes should create themes if none exist" do
    Theme.where(is_system: true).destroy_all
    assert_difference("Theme.count", 6) do
      Theme.seed_system_themes!
    end
  end

  test "seed_system_themes should be idempotent" do
    Theme.seed_system_themes!
    assert_no_difference("Theme.count") do
      Theme.seed_system_themes!
    end
  end
end
