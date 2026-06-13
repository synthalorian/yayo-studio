require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(
      email: "test@example.com",
      name: "Test User",
      password: "password123",
      password_confirmation: "password123"
    )
    assert user.valid?
  end

  test "should require email" do
    user = User.new(email: "", name: "Test", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require valid email format" do
    user = User.new(email: "invalid-email", name: "Test", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "should require unique email" do
    existing = users(:synth)
    user = User.new(email: existing.email, name: "Test", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "should require name" do
    user = User.new(email: "test@example.com", name: "", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require password minimum length" do
    user = User.new(email: "test@example.com", name: "Test", password: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "default_theme should return synthwave-84" do
    assert_equal "synthwave-84", User.default_theme
  end

  test "should have many projects" do
    user = users(:synth)
    assert_respond_to user, :projects
    assert_equal 2, user.projects.count
  end

  test "destroying user should destroy projects" do
    user = users(:synth)
    project_count = user.projects.count
    assert_difference("Project.count", -project_count) do
      user.destroy
    end
  end
end
