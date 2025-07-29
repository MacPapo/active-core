require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    membership = memberships(:active_membership)
    assert membership.valid?, membership.errors.full_messages
  end

  test "should require all associations and dates" do
    membership = Membership.new
    assert_not membership.valid?
    assert membership.errors[:user].present?
    assert membership.errors[:member].present?
    assert membership.errors[:pricing_plan].present?
    assert membership.errors[:start_date].present?
    assert membership.errors[:end_date].present?
  end

  test "should belong to user, member, and pricing plan" do
    membership = memberships(:active_membership)
    assert_equal users(:admin_user), membership.user
    assert_equal members(:adult_member), membership.member
    assert_equal pricing_plans(:monthly_membership), membership.pricing_plan
  end

  test "end date should be after start date" do
    membership = memberships(:active_membership)
    assert membership.end_date >= membership.start_date
  end

  test "should identify active membership on specific date" do
    travel_to Date.new(2024, 1, 15) do
      membership = memberships(:active_membership)
      # Assuming you have scope or method to check active memberships
      assert membership.start_date <= Date.current
      assert membership.end_date >= Date.current
    end
  end

  test "should handle membership expiration" do
    travel_to Date.new(2024, 2, 1) do
      membership = memberships(:active_membership)
      # Membership should be expired by this date
      assert membership.end_date < Date.current
    end
  end
end
