require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    project = Project.new(
      name: "New Project",
      user: users(:synth),
      project_type: project_types(:game)
    )
    assert project.valid?
  end

  test "should require name" do
    project = Project.new(name: "", user: users(:synth))
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "should require user" do
    project = Project.new(name: "Test", project_type: project_types(:game))
    assert_not project.valid?
  end

  test "should require project_type" do
    project = Project.new(name: "Test", user: users(:synth))
    assert_not project.valid?
  end

  test "should validate status inclusion" do
    project = projects(:holy_lands)
    project.status = "invalid_status"
    assert_not project.valid?
    assert_includes project.errors[:status], "is not included in the list"
  end

  test "should validate repo_url format" do
    project = projects(:holy_lands)
    project.repo_url = "not-a-url"
    assert_not project.valid?
    assert_includes project.errors[:repo_url], "must be a valid URL"
  end

  test "should validate website_url format" do
    project = projects(:holy_lands)
    project.website_url = "not-a-url"
    assert_not project.valid?
    assert_includes project.errors[:website_url], "must be a valid URL"
  end

  test "active scope should return active projects" do
    active = Project.active
    assert_includes active, projects(:holy_lands)
    assert_includes active, projects(:open_habit)
  end

  test "archived scope should return archived projects" do
    projects(:holy_lands).update(status: "archived")
    archived = Project.archived
    assert_includes archived, projects(:holy_lands)
  end

  test "should have many journal entries" do
    project = projects(:holy_lands)
    assert_respond_to project, :journal_entries
    assert_equal 2, project.journal_entries.count
  end

  test "should have many assets" do
    project = projects(:holy_lands)
    assert_respond_to project, :assets
    assert_equal 2, project.assets.count
  end

  test "should have many ai integrations" do
    project = projects(:holy_lands)
    assert_respond_to project, :ai_integrations
  end

  test "destroying project should destroy dependent records" do
    project = projects(:holy_lands)
    assert_difference("JournalEntry.count", -2) do
      assert_difference("Asset.count", -2) do
        project.destroy
      end
    end
  end
end
