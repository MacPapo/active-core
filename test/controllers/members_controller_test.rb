require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin_user)
    sign_in @user
    @member = members(:adult_member)
    @pricing_plan = pricing_plans(:annual_membership)
  end

  test "should get index" do
    get members_url
    assert_response :success
  end

  test "should get new" do
    get new_member_url
    assert_response :success
    assert_select "form[action=?]", members_path
    assert_select "select[name='pricing_plan_id']"
    assert_select "select[name='payment_method']"
  end

  test "should create member with membership" do
    assert_difference([ "Member.count", "Membership.count", "Payment.count" ]) do
      post members_url, params: {
             member: { name: "Mario", surname: "Rossi", email: "mario_#{Time.current.to_i}@test.com", birth_day: "1999-01-01", affiliated: false },
             pricing_plan_id: @pricing_plan.id,
             payment_method: "cash"
           }
    end

    member = Member.last
    assert_redirected_to member_url(member)
    assert member.active_membership?
    follow_redirect!
    assert_select ".notice", "Membro registrato e iscritto con successo!"
  end

  test "should not create member without pricing plan" do
    assert_no_difference "Member.count" do
      post members_url, params: {
             member: { name: "Mario", surname: "Rossi", birth_day: "2002-01-01", affiliated: false }
           }
    end
    assert_response :unprocessable_entity
  end

  test "should show member with stats" do
    get member_url(@member)
    assert_response :success
  end

  test "should filter by membership status" do
    get members_url, params: { membership_status: "active" }
    assert_response :success
  end
end
