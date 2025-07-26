require "test_helper"

class PricingPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin_user)
    @product = products(:activity_product)
    @pricing_plan = pricing_plans(:activity_session)
    sign_in @user
  end

  test "should get new" do
    get new_product_pricing_plan_path(@product)
    assert_response :success
    assert_select "form"
  end

  test "should create pricing plan" do
    assert_difference("PricingPlan.count") do
      post product_pricing_plans_path(@product), params: {
             pricing_plan: {
               duration_type: "months",
               duration_value: 6,
               price: 150.00,
               affiliated_price: 120.00,
               active: true
             }
           }
    end

    assert_redirected_to product_path(@product)
  end

  test "should not create invalid pricing plan" do
    assert_no_difference("PricingPlan.count") do
      post product_pricing_plans_path(@product), params: {
             pricing_plan: { duration_type: "", price: "" }
           }
    end

    assert_response :unprocessable_content
  end

  test "should update pricing plan" do
    patch product_pricing_plan_path(@product, @pricing_plan), params: {
            pricing_plan: { price: 99.99 }
          }

    assert_redirected_to product_pricing_plan_path(@product, @pricing_plan)
    assert_equal 99.99, @pricing_plan.reload.price
  end

  test "should destroy pricing plan" do
    assert_difference("@product.pricing_plans.kept.count", -1) do
      delete product_pricing_plan_path(@product, @pricing_plan)
    end

    assert_redirected_to product_path(@product)
  end
end
