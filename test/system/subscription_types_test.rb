require "application_system_test_case"

class SubscriptionTypesTest < ApplicationSystemTestCase
  setup do
    @subscription_type = subscription_types(:one)
  end

  test "visiting the index" do
    visit subscription_types_url
    assert_selector "h1", text: "Subscription types"
  end

  test "should create subscription type" do
    visit subscription_types_url
    click_on "New subscription type"

    fill_in "Cost", with: @subscription_type.cost
    fill_in "Desc", with: @subscription_type.desc
    fill_in "Duration", with: @subscription_type.duration
    click_on "Create Subscription type"

    assert_text "Subscription type was successfully created"
    click_on "Back"
  end

  test "should update Subscription type" do
    visit subscription_type_url(@subscription_type)
    click_on "Edit this subscription type", match: :first

    fill_in "Cost", with: @subscription_type.cost
    fill_in "Desc", with: @subscription_type.desc
    fill_in "Duration", with: @subscription_type.duration
    click_on "Update Subscription type"

    assert_text "Subscription type was successfully updated"
    click_on "Back"
  end

  test "should destroy Subscription type" do
    visit subscription_type_url(@subscription_type)
    click_on "Destroy this subscription type", match: :first

    assert_text "Subscription type was successfully destroyed"
  end
end
