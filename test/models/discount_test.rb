require "test_helper"

class DiscountTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    discount = discounts(:student_discount)
    assert discount.valid?, discount.errors.full_messages
  end

  test "should require name and value" do
    discount = Discount.new(discount_type: 0, applicable_to: 0)
    assert_not discount.valid?
    assert discount.errors[:name].present?
    assert discount.errors[:value].present?
  end

  test "should have unique name" do
    existing_discount = discounts(:student_discount)
    discount = Discount.new(
      name: existing_discount.name,
      discount_type: 0,
      value: 5.0,
      applicable_to: 0
    )
    assert_not discount.valid?
    assert discount.errors[:name].present?
  end

  test "percentage discount should have reasonable value" do
    discount = discounts(:student_discount)
    assert discount.value <= 100.0  # assuming percentage <= 100%
  end

  test "should apply discount within valid period" do
    travel_to Date.new(2024, 6, 15) do
      discount = discounts(:student_discount)
      current_date = Date.current

      if discount.valid_from && discount.valid_until
        assert discount.valid_from <= current_date
        assert discount.valid_until >= current_date
      end
    end
  end

  test "should not apply expired discount" do
    travel_to Date.new(2025, 1, 15) do
      discount = discounts(:student_discount)
      # Discount should be expired by this date
      if discount.valid_until
        assert discount.valid_until < Date.current
      end
    end
  end
end
