require "test_helper"

class WaitlistTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    waitlist = waitlists(:yoga_waitlist)
    assert waitlist.valid?, waitlist.errors.full_messages
  end

  test "should require member and product" do
    waitlist = Waitlist.new
    assert_not waitlist.valid?
    assert waitlist.errors[:member].present?
    assert waitlist.errors[:product].present?
  end

  test "should have unique member and product combination" do
    existing_waitlist = waitlists(:yoga_waitlist)
    waitlist = Waitlist.new(
      member: existing_waitlist.member,
      product: existing_waitlist.product,
      priority: 1
    )
    assert_not waitlist.valid?
    assert waitlist.errors.present?
  end

  test "should belong to member and product" do
    waitlist = waitlists(:yoga_waitlist)
    assert_equal members(:minor_member), waitlist.member
    assert_equal products(:activity_product), waitlist.product
  end
end
