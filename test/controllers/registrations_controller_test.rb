require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get signup page" do
    get signup_url
    assert_response :success
  end

  test "should create user with valid params" do
    assert_difference("User.count") do
      post signup_url, params: {
        user: {
          name: "New User",
          email: "new@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to dashboard_path
    assert_not_nil session[:user_id]
  end

  test "should not create user with invalid params" do
    assert_no_difference("User.count") do
      post signup_url, params: {
        user: {
          name: "",
          email: "invalid",
          password: "short",
          password_confirmation: "mismatch"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not access signup when already logged in" do
    user = users(:synth)
    post login_url, params: { email: user.email, password: "yayo_studio" }

    get signup_url
    assert_redirected_to dashboard_path
  end
end
