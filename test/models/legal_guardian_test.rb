require "test_helper"

class LegalGuardianTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    guardian = legal_guardians(:one)
    assert guardian.valid?, guardian.errors.full_messages
  end

  test "should require all mandatory fields" do
    guardian = LegalGuardian.new
    assert_not guardian.valid?
    assert guardian.errors[:name].present?
    assert guardian.errors[:surname].present?
    assert guardian.errors[:email].present?
    assert guardian.errors[:phone].present?
    assert guardian.errors[:birth_day].present?
  end

  test "should have unique email" do
    existing_guardian = legal_guardians(:one)
    guardian = LegalGuardian.new(
      name: "Test",
      surname: "User",
      email: existing_guardian.email,
      phone: "123456789",
      birth_day: existing_guardian.birth_day
    )
    assert_not guardian.valid?
    assert guardian.errors[:email].present?, guardian.errors.full_messages
  end
end
