require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    product = products(:membership_product)
    assert product.valid?, product.errors.full_messages
  end

  test "should require name and product_type" do
    product = Product.new
    assert_not product.valid?
    assert product.errors[:name].present?
    assert product.errors[:product_type].present?
  end

  test "should have unique name and product_type combination" do
    existing_product = products(:membership_product)
    product = Product.new(
      name: existing_product.name,
      product_type: existing_product.product_type
    )
    assert_not product.valid?
    assert product.errors.present?
  end

  test "should have pricing plans" do
    product = products(:membership_product)
    assert_includes product.pricing_plans, pricing_plans(:monthly_membership)
  end
end
