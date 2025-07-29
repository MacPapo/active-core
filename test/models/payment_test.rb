require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    payment = payments(:membership_payment)
    assert payment.valid?, payment.errors.full_messages
  end

  test "should require user and amounts" do
    payment = Payment.new
    assert_not payment.valid?
    assert payment.errors[:user].present?
    assert payment.errors[:total_amount].present?
    assert payment.errors[:final_amount].present?
  end

  test "should belong to user" do
    payment = payments(:membership_payment)
    assert_equal users(:admin_user), payment.user
  end

  test "should have payment items" do
    payment = payments(:membership_payment)
    assert_includes payment.payment_items, payment_items(:membership_item)
  end

  test "final amount should equal total minus discount" do
    payment = payments(:membership_payment)
    expected = payment.total_amount - payment.discount_amount
    assert_equal expected, payment.final_amount
  end
end
