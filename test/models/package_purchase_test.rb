require "test_helper"

class PackagePurchaseTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    purchase = package_purchases(:active_package)
    assert purchase.valid?, purchase.errors.full_messages
  end

  test "should require all associations" do
    purchase = PackagePurchase.new
    assert_not purchase.valid?
    assert purchase.errors[:member].present?
    assert purchase.errors[:package].present?
    assert purchase.errors[:user].present?
  end

  test "should belong to member, package, and user" do
    purchase = package_purchases(:active_package)
    assert_equal members(:adult_member), purchase.member
    assert_equal packages(:beginner_package), purchase.package
    assert_equal users(:admin_user), purchase.user
  end
end
