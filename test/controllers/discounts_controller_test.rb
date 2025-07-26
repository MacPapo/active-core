require "test_helper"

class DiscountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @discount = discounts(:student_discount)
    sign_in @admin_user
  end

  test "should get index" do
    get discounts_url
    assert_response :success
  end

  test "should get new" do
    get new_discount_url
    assert_response :success
  end

  test "should create discount" do
    assert_difference("Discount.count") do
      post discounts_url, params: {
             discount: {
               name: "Test Discount",
               discount_type: "percentage",
               value: 10,
               applicable_to: "all_services",
               active: true
             }
           }
    end

    assert_redirected_to discount_url(Discount.last)
  end

  test "should show discount" do
    get discount_url(@discount)
    assert_response :success
  end

  test "should update discount" do
    patch discount_url(@discount), params: {
            discount: { name: "Updated Name" }
          }
    assert_redirected_to discount_url(@discount)
  end

  test "should destroy discount" do
    delete discount_url(@discount)
    assert_redirected_to discounts_url
    assert @discount.reload.discarded?
  end
end
