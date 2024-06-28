require "test_helper"

class SubscriptionTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscription_type = subscription_types(:one)
  end

  test "should get index" do
    get subscription_types_url
    assert_response :success
  end

  test "should get new" do
    get new_subscription_type_url
    assert_response :success
  end

  test "should create subscription_type" do
    assert_difference("SubscriptionType.count") do
      post subscription_types_url, params: { subscription_type: { cost: @subscription_type.cost, desc: @subscription_type.desc, duration: @subscription_type.duration } }
    end

    assert_redirected_to subscription_type_url(SubscriptionType.last)
  end

  test "should show subscription_type" do
    get subscription_type_url(@subscription_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_subscription_type_url(@subscription_type)
    assert_response :success
  end

  test "should update subscription_type" do
    patch subscription_type_url(@subscription_type), params: { subscription_type: { cost: @subscription_type.cost, desc: @subscription_type.desc, duration: @subscription_type.duration } }
    assert_redirected_to subscription_type_url(@subscription_type)
  end

  test "should destroy subscription_type" do
    assert_difference("SubscriptionType.count", -1) do
      delete subscription_type_url(@subscription_type)
    end

    assert_redirected_to subscription_types_url
  end
end
