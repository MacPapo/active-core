# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    user = users(:regular_user)
    user.password = "password"
    assert user.valid?, user.errors.full_messages
  end

  test "should require nickname and member" do
    user = User.new
    assert_not user.valid?
    assert user.errors[:nickname].present?
    assert user.errors[:member].present?
    assert user.errors[:password].present?
  end

  test "should have unique nickname" do
    existing_user = users(:admin_user)
    user = User.new(
      nickname: existing_user.nickname,
      member: members(:minor_member),
      password: "password123"
    )
    assert_not user.valid?
    assert user.errors[:nickname].present?
  end

  test "should belong to member" do
    user = users(:admin_user)
    assert_equal members(:adult_member), user.member
  end

  test "should validate nickname format" do
    user = User.new(
      nickname: "invalid-nickname!",
      member: members(:minor_member),
      password: "password123"
    )
    assert_not user.valid?
    assert user.errors[:nickname].present?
  end

  test "should normalize nickname to lowercase" do
    user = User.new(
      nickname: "TestUser",
      member: members(:minor_member),
      password: "password123"
    )
    user.valid? # triggers normalization
    assert_equal "testuser", user.nickname
  end
end
