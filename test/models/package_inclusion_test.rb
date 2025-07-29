require "test_helper"

class PackageInclusionTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    inclusion = package_inclusions(:package_activity)
    assert inclusion.valid?, inclusion.errors.full_messages
  end

  test "should require package and product" do
    inclusion = PackageInclusion.new
    assert_not inclusion.valid?
    assert inclusion.errors[:package].present?
    assert inclusion.errors[:product].present?
  end

  test "should have unique package and product combination" do
    existing_inclusion = package_inclusions(:package_activity)
    inclusion = PackageInclusion.new(
      package: existing_inclusion.package,
      product: existing_inclusion.product,
      access_type: 0
    )
    assert_not inclusion.valid?
    assert inclusion.errors.present?
  end

  test "should belong to package and product" do
    inclusion = package_inclusions(:package_activity)
    assert_equal packages(:beginner_package), inclusion.package
    assert_equal products(:activity_product), inclusion.product
  end

  test "should not allow membership products in packages" do
    inclusion = PackageInclusion.new(
      package: packages(:beginner_package),
      product: products(:membership_product),
      access_type: 0
    )
    assert_not inclusion.valid?
    assert inclusion.errors.present?
  end
end
