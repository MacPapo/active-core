require "test_helper"

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @member = members(:adult_member)
    @membership = memberships(:active_membership)
    @pricing_plan = pricing_plans(:annual_membership)
    sign_in @admin
  end

  test "should get index" do
    get memberships_path
    assert_response :success
    assert_select "table"
  end

  test "should show membership" do
    get member_membership_path(@member, @membership)
    assert_response :success
    assert_select "h1", text: /Membership di/
  end

  test "should get edit" do
    get edit_membership_path(@membership)
    assert_response :success
  end

  test "should update membership" do
    patch membership_path(@membership), params: {
            membership: { status: "suspended" }
          }

    assert_redirected_to membership_path(@membership)
    assert_equal "suspended", @membership.reload.status
  end

  test "should create renewal membership" do
    @membership.update!(status: :expired)

    assert_difference("Membership.count") do
      post member_memberships_path(@member), params: {
             membership: {
               pricing_plan_id: @pricing_plan.id,
               payment_method: "cash"
             }
           }
    end

    new_membership = Membership.last
    assert_equal @membership, new_membership.renewed_from
    assert_redirected_to @member
  end

  test "should destroy membership" do
    assert_difference("@member.memberships.kept.count", -1) do
      delete member_membership_path(@member, @membership)
    end

    assert_redirected_to member_path(@member)
  end

  test "should filter by status" do
    get memberships_path, params: { status: "active" }
    assert_response :success
  end

  test "should filter expiring soon" do
    get memberships_path, params: { expiring_soon: "true" }
    assert_response :success
  end
end
