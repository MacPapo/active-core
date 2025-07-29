require "test_helper"

class PaymentItemTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    item = payment_items(:membership_item)
    assert item.valid?, item.errors.full_messages
  end

  test "should require payment and amount" do
    item = PaymentItem.new
    assert_not item.valid?
    assert item.errors[:payment].present?
    assert item.errors[:amount].present?
  end

  test "should belong to payment" do
    item = payment_items(:membership_item)
    assert_equal payments(:membership_payment), item.payment
  end

  test "should have polymorphic payable association" do
    item = payment_items(:membership_item)
    assert_equal memberships(:active_membership), item.payable
  end
end
