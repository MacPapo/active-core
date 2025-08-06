require "application_system_test_case"

class AccessGrantsTest < ApplicationSystemTestCase
  setup do
    @access_grant = access_grants(:one)
  end

  test "visiting the index" do
    visit access_grants_url
    assert_selector "h1", text: "Access grants"
  end

  test "should create access grant" do
    visit access_grants_url
    click_on "New access grant"

    click_on "Create Access grant"

    assert_text "Access grant was successfully created"
    click_on "Back"
  end

  test "should update Access grant" do
    visit access_grant_url(@access_grant)
    click_on "Edit this access grant", match: :first

    click_on "Update Access grant"

    assert_text "Access grant was successfully updated"
    click_on "Back"
  end

  test "should destroy Access grant" do
    visit access_grant_url(@access_grant)
    click_on "Destroy this access grant", match: :first

    assert_text "Access grant was successfully destroyed"
  end
end
