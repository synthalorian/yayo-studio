require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when not authenticated" do
    get dashboard_url
    assert_redirected_to login_path
  end

  test "should show dashboard when authenticated" do
    user = users(:synth)
    post login_url, params: { email: user.email, password: "yayo_studio" }

    get dashboard_url
    assert_response :success
  end
end
