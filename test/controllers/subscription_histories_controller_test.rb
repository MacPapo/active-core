require "test_helper"

class SubscriptionHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscription_history = subscription_histories(:one)
  end

  test "should get index" do
    get subscription_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_subscription_history_url
    assert_response :success
  end

  test "should create subscription_history" do
    assert_difference("SubscriptionHistory.count") do
      post subscription_histories_url, params: { subscription_history: { action: @subscription_history.action, new_end_date: @subscription_history.new_end_date, old_end_date: @subscription_history.old_end_date, renewal_date: @subscription_history.renewal_date, staff_id: @subscription_history.staff_id, subscription_id: @subscription_history.subscription_id } }
    end

    assert_redirected_to subscription_history_url(SubscriptionHistory.last)
  end

  test "should show subscription_history" do
    get subscription_history_url(@subscription_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_subscription_history_url(@subscription_history)
    assert_response :success
  end

  test "should update subscription_history" do
    patch subscription_history_url(@subscription_history), params: { subscription_history: { action: @subscription_history.action, new_end_date: @subscription_history.new_end_date, old_end_date: @subscription_history.old_end_date, renewal_date: @subscription_history.renewal_date, staff_id: @subscription_history.staff_id, subscription_id: @subscription_history.subscription_id } }
    assert_redirected_to subscription_history_url(@subscription_history)
  end

  test "should destroy subscription_history" do
    assert_difference("SubscriptionHistory.count", -1) do
      delete subscription_history_url(@subscription_history)
    end

    assert_redirected_to subscription_histories_url
  end
end
