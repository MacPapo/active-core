require "application_system_test_case"

class PricingPlansTest < ApplicationSystemTestCase
  setup do
    @pricing_plan = pricing_plans(:one)
  end

  test "visiting the index" do
    visit pricing_plans_url
    assert_selector "h1", text: "Pricing plans"
  end

  test "should create pricing plan" do
    visit pricing_plans_url
    click_on "New pricing plan"

    click_on "Create Pricing plan"

    assert_text "Pricing plan was successfully created"
    click_on "Back"
  end

  test "should update Pricing plan" do
    visit pricing_plan_url(@pricing_plan)
    click_on "Edit this pricing plan", match: :first

    click_on "Update Pricing plan"

    assert_text "Pricing plan was successfully updated"
    click_on "Back"
  end

  test "should destroy Pricing plan" do
    visit pricing_plan_url(@pricing_plan)
    click_on "Destroy this pricing plan", match: :first

    assert_text "Pricing plan was successfully destroyed"
  end
end
