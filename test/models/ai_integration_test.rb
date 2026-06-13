require "test_helper"

class AiIntegrationTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    integration = AiIntegration.new(
      name: "Test Integration",
      provider: "openai",
      project: projects(:holy_lands)
    )
    assert integration.valid?
  end

  test "should require name" do
    integration = AiIntegration.new(name: "", provider: "openai", project: projects(:holy_lands))
    assert_not integration.valid?
    assert_includes integration.errors[:name], "can't be blank"
  end

  test "should require provider" do
    integration = AiIntegration.new(name: "Test", provider: "", project: projects(:holy_lands))
    assert_not integration.valid?
    assert_includes integration.errors[:provider], "can't be blank"
  end

  test "should validate provider inclusion" do
    integration = ai_integrations(:ai_one)
    integration.provider = "invalid_provider"
    assert_not integration.valid?
    assert_includes integration.errors[:provider], "is not included in the list"
  end

  test "should validate endpoint_url format" do
    integration = ai_integrations(:ai_one)
    integration.endpoint_url = "not-a-url"
    assert_not integration.valid?
    assert_includes integration.errors[:endpoint_url], "must be a valid URL"
  end

  test "should validate status inclusion" do
    integration = ai_integrations(:ai_one)
    integration.status = "invalid_status"
    assert_not integration.valid?
    assert_includes integration.errors[:status], "is not included in the list"
  end

  test "enabled scope should return enabled integrations" do
    enabled = AiIntegration.enabled
    assert_includes enabled, ai_integrations(:ai_one)
    assert_not_includes enabled, ai_integrations(:ai_two)
  end

  test "connected scope should return connected integrations" do
    connected = AiIntegration.connected
    assert_includes connected, ai_integrations(:ai_one)
  end

  test "health_status should return correct status" do
    integration = ai_integrations(:ai_one)
    assert_equal "connected", integration.health_status
  end

  test "set_defaults should set status and harness_type before save" do
    AiIntegration.skip_callback(:commit, :after, :auto_discover_harness, on: :create)

    integration = AiIntegration.create!(
      name: "Test",
      provider: "openai",
      project: projects(:holy_lands)
    )
    assert_equal "unknown", integration.status
    assert_equal "openai", integration.harness_type
  ensure
    AiIntegration.set_callback(:commit, :after, :auto_discover_harness, on: :create)
  end
end
