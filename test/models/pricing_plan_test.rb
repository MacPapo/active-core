require "test_helper"

class PricingPlanTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    plan = pricing_plans(:monthly_membership)
    assert plan.valid?, plan.errors.full_messages
  end

  test "should require product and price" do
    plan = PricingPlan.new
    assert_not plan.valid?
    assert plan.errors[:product].present?
    assert plan.errors[:price].present?
  end

  test "should belong to product" do
    plan = pricing_plans(:monthly_membership)
    assert_equal products(:membership_product), plan.product
  end

  test "should have affiliated price lower than regular price" do
    plan = pricing_plans(:monthly_membership)
    assert plan.affiliated_price < plan.price
  end
end
