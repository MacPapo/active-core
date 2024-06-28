require "test_helper"

class LegalGuardiansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @legal_guardian = legal_guardians(:one)
  end

  test "should get index" do
    get legal_guardians_url
    assert_response :success
  end

  test "should get new" do
    get new_legal_guardian_url
    assert_response :success
  end

  test "should create legal_guardian" do
    assert_difference("LegalGuardian.count") do
      post legal_guardians_url, params: { legal_guardian: { date_of_birth: @legal_guardian.date_of_birth, email: @legal_guardian.email, name: @legal_guardian.name, phone: @legal_guardian.phone, surname: @legal_guardian.surname } }
    end

    assert_redirected_to legal_guardian_url(LegalGuardian.last)
  end

  test "should show legal_guardian" do
    get legal_guardian_url(@legal_guardian)
    assert_response :success
  end

  test "should get edit" do
    get edit_legal_guardian_url(@legal_guardian)
    assert_response :success
  end

  test "should update legal_guardian" do
    patch legal_guardian_url(@legal_guardian), params: { legal_guardian: { date_of_birth: @legal_guardian.date_of_birth, email: @legal_guardian.email, name: @legal_guardian.name, phone: @legal_guardian.phone, surname: @legal_guardian.surname } }
    assert_redirected_to legal_guardian_url(@legal_guardian)
  end

  test "should destroy legal_guardian" do
    assert_difference("LegalGuardian.count", -1) do
      delete legal_guardian_url(@legal_guardian)
    end

    assert_redirected_to legal_guardians_url
  end
end
