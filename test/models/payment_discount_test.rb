require "test_helper"

class PaymentDiscountTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    payment_discount = payment_discounts(:applied_discount)
    assert payment_discount.valid?, payment_discount.errors.full_messages
  end

  test "should require payment, discount, and amount" do
    payment_discount = PaymentDiscount.new
    assert_not payment_discount.valid?
    assert payment_discount.errors[:payment].present?
    assert payment_discount.errors[:discount].present?
    assert payment_discount.errors[:discount_amount].present?
  end

  test "should have unique payment and discount combination" do
    existing_payment_discount = payment_discounts(:applied_discount)
    payment_discount = PaymentDiscount.new(
      payment: existing_payment_discount.payment,
      discount: existing_payment_discount.discount,
      discount_amount: 10.0
    )
    assert_not payment_discount.valid?
    assert payment_discount.errors.present?
  end

  test "should belong to payment and discount" do
    payment_discount = payment_discounts(:applied_discount)
    assert_equal payments(:membership_payment), payment_discount.payment
    assert_equal discounts(:student_discount), payment_discount.discount
  end
end
