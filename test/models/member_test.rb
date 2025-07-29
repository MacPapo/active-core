# test/models/member_test.rb
require "test_helper"

class MemberTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    member = members(:adult_member)
    assert member.valid?, member.errors.full_messages
  end

  test "should require name and surname" do
    member = Member.new
    assert_not member.valid?
    assert member.errors[:name].present?
    assert member.errors[:surname].present?
  end

  test "should have unique email when present" do
    existing_member = members(:adult_member)
    member = Member.new(
      name: "Test",
      surname: "User",
      email: existing_member.email,
      birth_day: existing_member.birth_day
    )
    assert_not member.valid?
    assert member.errors[:email].present?, member.errors.full_messages
  end

  test "minor member should have legal guardian" do
    member = members(:minor_member)
    assert_not_nil member.legal_guardian
    assert_equal "Luigi", member.legal_guardian.name
  end
end
