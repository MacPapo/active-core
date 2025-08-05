require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @collaborator = users(:collaborator_user)
    @member = members(:adult_member)
    @product = products(:activity_product)
    @pricing_plan = pricing_plans(:activity_session)
    @registration = registrations(:yoga_registration)
  end

  # NESTED ROUTES - Collaborator + Admin
  test "should create registration for member as collaborator" do
    sign_in @collaborator

    assert_difference("Registration.count") do
      post member_registrations_path(@member), params: {
             registration: {
               product_id: @product.id,
               pricing_plan_id: @pricing_plan.id,
               payment_method: "cash"
             }
           }
    end

    assert_redirected_to member_path(@member)
    assert_equal @member, Registration.last.member
  end

  test "should not create registration without active membership" do
    sign_in @admin

    @member.current_membership&.update!(status: :expired)

    assert_no_difference("Registration.count") do
      post member_registrations_path(@member), params: {
             registration: {
               product_id: @product.id,
               pricing_plan_id: @pricing_plan.id,
               payment_method: "cash"
             }
           }
    end

    assert_redirected_to member_path(@member)
  end

  test "should destroy registration as collaborator" do
    sign_in @collaborator

    assert_difference("Registration.kept.count", -1) do
      delete member_registration_path(@member, @registration)
    end

    assert_redirected_to member_path(@member)
  end

  # STANDALONE ROUTES - Solo Admin
  test "should get edit registration as admin" do
    sign_in @admin

    get edit_registration_path(@registration)
    assert_response :success
    assert_select "form"
  end

  test "should update registration as admin" do
    sign_in @admin

    patch registration_path(@registration), params: {
            registration: { status: "suspended" }
          }

    assert_redirected_to registrations_path
    assert_equal "suspended", @registration.reload.status
  end

  test "should not access admin routes as collaborator" do
    sign_in @collaborator

    get edit_registration_path(@registration)
    assert_redirected_to root_path
  end
end
