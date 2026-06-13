require "test_helper"

class AssetTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    asset = Asset.new(
      name: "Test Asset",
      project: projects(:holy_lands)
    )
    assert asset.valid?
  end

  test "should require name" do
    asset = Asset.new(name: "", project: projects(:holy_lands))
    assert_not asset.valid?
    assert_includes asset.errors[:name], "can't be blank"
  end

  test "should require project" do
    asset = Asset.new(name: "Test")
    assert_not asset.valid?
  end

  test "should validate asset_type inclusion" do
    asset = assets(:asset_one)
    asset.asset_type = "invalid_type"
    assert_not asset.valid?
    assert_includes asset.errors[:asset_type], "is not included in the list"
  end

  test "by_type scope should order by asset_type and name" do
    assets = Asset.by_type
    assert assets.first.asset_type <= assets.last.asset_type
  end
end
