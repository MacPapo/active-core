require "test_helper"

class RegistrationTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    registration = registrations(:yoga_registration)
    assert registration.valid?, registration.errors.full_messages
  end

  test "should require all associations" do
    registration = Registration.new
    assert_not registration.valid?
    assert registration.errors[:user].present?
    assert registration.errors[:member].present?
    assert registration.errors[:product].present?
    assert registration.errors[:pricing_plan].present?
  end

  test "should belong to all required associations" do
    registration = registrations(:yoga_registration)
    assert_equal users(:admin_user), registration.user
    assert_equal members(:adult_member), registration.member
    assert_equal products(:activity_product), registration.product
    assert_equal pricing_plans(:activity_session), registration.pricing_plan
  end

  test "should track sessions remaining" do
    registration = registrations(:yoga_registration)
    assert_equal 3, registration.sessions_remaining
  end
end
