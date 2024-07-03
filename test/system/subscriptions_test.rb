require "application_system_test_case"

class SubscriptionsTest < ApplicationSystemTestCase
  setup do
    @subscription = subscriptions(:one)
  end

  test "visiting the index" do
    visit subscriptions_url
    assert_selector "h1", text: "Subscriptions"
  end

  test "should create subscription" do
    visit subscriptions_url
    click_on "New subscription"

    fill_in "Course", with: @subscription.course_id
    fill_in "End", with: @subscription.end
    fill_in "Start", with: @subscription.start
    fill_in "State", with: @subscription.state
    fill_in "Subscription type", with: @subscription.subscription_type_id
    fill_in "User", with: @subscription.user_id
    click_on "Create Subscription"

    assert_text "Subscription was successfully created"
    click_on "Back"
  end

  test "should update Subscription" do
    visit subscription_url(@subscription)
    click_on "Edit this subscription", match: :first

    fill_in "Course", with: @subscription.course_id
    fill_in "End", with: @subscription.end
    fill_in "Start", with: @subscription.start
    fill_in "State", with: @subscription.state
    fill_in "Subscription type", with: @subscription.subscription_type_id
    fill_in "User", with: @subscription.user_id
    click_on "Update Subscription"

    assert_text "Subscription was successfully updated"
    click_on "Back"
  end

  test "should destroy Subscription" do
    visit subscription_url(@subscription)
    click_on "Destroy this subscription", match: :first

    assert_text "Subscription was successfully destroyed"
  end
end
