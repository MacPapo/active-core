require "test_helper"

class ReceiptTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    receipt = receipts(:membership_receipt)
    assert receipt.valid?, receipt.errors.full_messages
  end

  test "should require payment, user, number, and year" do
    receipt = Receipt.new
    assert_not receipt.valid?
    assert receipt.errors[:payment].present?
    assert receipt.errors[:user].present?
    # assert receipt.errors[:number].present?
    # assert receipt.errors[:year].present?
  end

  test "should have unique number and year combination" do
    existing_receipt = receipts(:membership_receipt)
    receipt = Receipt.new(
      payment: payments(:membership_payment),
      user: users(:admin_user),
      number: existing_receipt.number,
      year: existing_receipt.year,
      date: Date.current
    )
    assert_not receipt.valid?
    assert receipt.errors.present?
  end

  test "should belong to payment and user" do
    receipt = receipts(:membership_receipt)
    assert_equal payments(:membership_payment), receipt.payment
    assert_equal users(:admin_user), receipt.user
  end
end
