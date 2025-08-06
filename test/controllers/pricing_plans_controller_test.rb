require "test_helper"

class PricingPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pricing_plan = pricing_plans(:one)
  end

  test "should get index" do
    get pricing_plans_url
    assert_response :success
  end

  test "should get new" do
    get new_pricing_plan_url
    assert_response :success
  end

  test "should create pricing_plan" do
    assert_difference("PricingPlan.count") do
      post pricing_plans_url, params: { pricing_plan: {} }
    end

    assert_redirected_to pricing_plan_url(PricingPlan.last)
  end

  test "should show pricing_plan" do
    get pricing_plan_url(@pricing_plan)
    assert_response :success
  end

  test "should get edit" do
    get edit_pricing_plan_url(@pricing_plan)
    assert_response :success
  end

  test "should update pricing_plan" do
    patch pricing_plan_url(@pricing_plan), params: { pricing_plan: {} }
    assert_redirected_to pricing_plan_url(@pricing_plan)
  end

  test "should destroy pricing_plan" do
    assert_difference("PricingPlan.count", -1) do
      delete pricing_plan_url(@pricing_plan)
    end

    assert_redirected_to pricing_plans_url
  end
end
