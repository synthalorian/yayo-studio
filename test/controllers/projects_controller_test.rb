require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:synth)
    post login_url, params: { email: @user.email, password: "yayo_studio" }
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: {
        project: {
          name: "New Project",
          description: "A test project",
          project_type_id: project_types(:game).id,
          status: "active"
        }
      }
    end
    assert_redirected_to project_url(Project.last)
  end

  test "should show project" do
    project = projects(:holy_lands)
    get project_url(project)
    assert_response :success
  end

  test "should get edit" do
    project = projects(:holy_lands)
    get edit_project_url(project)
    assert_response :success
  end

  test "should update project" do
    project = projects(:holy_lands)
    patch project_url(project), params: {
      project: {
        name: "Updated Name"
      }
    }
    assert_redirected_to project_url(project)
    assert_equal "Updated Name", project.reload.name
  end

  test "should destroy project" do
    project = projects(:holy_lands)
    assert_difference("Project.count", -1) do
      delete project_url(project)
    end
    assert_redirected_to projects_url
  end

  test "should not access other user's project" do
    other_project = projects(:another_project)
    get project_url(other_project)
    assert_response :not_found
  end
end
