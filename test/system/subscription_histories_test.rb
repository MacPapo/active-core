require "application_system_test_case"

class SubscriptionHistoriesTest < ApplicationSystemTestCase
  setup do
    @subscription_history = subscription_histories(:one)
  end

  test "visiting the index" do
    visit subscription_histories_url
    assert_selector "h1", text: "Subscription histories"
  end

  test "should create subscription history" do
    visit subscription_histories_url
    click_on "New subscription history"

    fill_in "Action", with: @subscription_history.action
    fill_in "New end date", with: @subscription_history.new_end_date
    fill_in "Old end date", with: @subscription_history.old_end_date
    fill_in "Renewal date", with: @subscription_history.renewal_date
    fill_in "Staff", with: @subscription_history.staff_id
    fill_in "Subscription", with: @subscription_history.subscription_id
    click_on "Create Subscription history"

    assert_text "Subscription history was successfully created"
    click_on "Back"
  end

  test "should update Subscription history" do
    visit subscription_history_url(@subscription_history)
    click_on "Edit this subscription history", match: :first

    fill_in "Action", with: @subscription_history.action
    fill_in "New end date", with: @subscription_history.new_end_date
    fill_in "Old end date", with: @subscription_history.old_end_date
    fill_in "Renewal date", with: @subscription_history.renewal_date
    fill_in "Staff", with: @subscription_history.staff_id
    fill_in "Subscription", with: @subscription_history.subscription_id
    click_on "Update Subscription history"

    assert_text "Subscription history was successfully updated"
    click_on "Back"
  end

  test "should destroy Subscription history" do
    visit subscription_history_url(@subscription_history)
    click_on "Destroy this subscription history", match: :first

    assert_text "Subscription history was successfully destroyed"
  end
end
