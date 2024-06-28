require "application_system_test_case"

class LegalGuardiansTest < ApplicationSystemTestCase
  setup do
    @legal_guardian = legal_guardians(:one)
  end

  test "visiting the index" do
    visit legal_guardians_url
    assert_selector "h1", text: "Legal guardians"
  end

  test "should create legal guardian" do
    visit legal_guardians_url
    click_on "New legal guardian"

    fill_in "Date of birth", with: @legal_guardian.date_of_birth
    fill_in "Email", with: @legal_guardian.email
    fill_in "Name", with: @legal_guardian.name
    fill_in "Phone", with: @legal_guardian.phone
    fill_in "Surname", with: @legal_guardian.surname
    click_on "Create Legal guardian"

    assert_text "Legal guardian was successfully created"
    click_on "Back"
  end

  test "should update Legal guardian" do
    visit legal_guardian_url(@legal_guardian)
    click_on "Edit this legal guardian", match: :first

    fill_in "Date of birth", with: @legal_guardian.date_of_birth
    fill_in "Email", with: @legal_guardian.email
    fill_in "Name", with: @legal_guardian.name
    fill_in "Phone", with: @legal_guardian.phone
    fill_in "Surname", with: @legal_guardian.surname
    click_on "Update Legal guardian"

    assert_text "Legal guardian was successfully updated"
    click_on "Back"
  end

  test "should destroy Legal guardian" do
    visit legal_guardian_url(@legal_guardian)
    click_on "Destroy this legal guardian", match: :first

    assert_text "Legal guardian was successfully destroyed"
  end
end
