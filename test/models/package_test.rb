require "test_helper"

class PackageTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    package = packages(:beginner_package)
    assert package.valid?, package.errors.full_messages
  end

  test "should require name and price" do
    package = Package.new
    assert_not package.valid?
    assert package.errors[:name].present?
    assert package.errors[:price].present?
  end

  test "should have unique name" do
    existing_package = packages(:beginner_package)
    package = Package.new(
      name: existing_package.name,
      price: 50.0,
      duration_type: 1,
      duration_value: 1
    )
    assert_not package.valid?
    assert package.errors[:name].present?
  end

  test "should have package inclusions" do
    package = packages(:beginner_package)
    assert_includes package.package_inclusions, package_inclusions(:package_activity)
  end

  test "should respect package validity dates" do
    travel_to Date.new(2024, 6, 15) do
      package = packages(:beginner_package)
      current_date = Date.current

      if package.valid_from && package.valid_until
        assert package.valid_from <= current_date
        assert package.valid_until >= current_date
      end
    end
  end

  test "should handle package expiration" do
    travel_to Date.new(2025, 1, 15) do
      package = packages(:beginner_package)
      # Package should be expired by this date
      if package.valid_until
        assert package.valid_until < Date.current
      end
    end
  end
end
