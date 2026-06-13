require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get login_url
    assert_response :success
  end

  test "should login with valid credentials" do
    user = users(:synth)
    post login_url, params: { email: user.email, password: "yayo_studio" }
    assert_redirected_to dashboard_path
    assert_equal user.id, session[:user_id]
  end

  test "should not login with invalid credentials" do
    post login_url, params: { email: "wrong@example.com", password: "wrong" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should logout" do
    user = users(:synth)
    post login_url, params: { email: user.email, password: "yayo_studio" }
    assert_equal user.id, session[:user_id]

    delete logout_url
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end

  test "should not access login when already logged in" do
    user = users(:synth)
    post login_url, params: { email: user.email, password: "yayo_studio" }

    get login_url
    assert_redirected_to dashboard_path
  end
end
