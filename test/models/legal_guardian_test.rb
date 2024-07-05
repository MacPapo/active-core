require "test_helper"

class LegalGuardianTest < ActiveSupport::TestCase
  def setup
    @legal_guardian = LegalGuardian.create!(
      name: "John",
      surname: "Doe",
      email: "john.doe@example.com",
      phone: "1234567890",
      date_of_birth: Date.new(1980, 1, 1)
    )
  end

  test "should be valid with all attributes" do
    assert @legal_guardian.valid?
  end

  # test "should be invalid without name" do
  #   @legal_guardian.name = nil
  #   assert_not @legal_guardian.valid?
  #   assert_includes @legal_guardian.errors[:name], "can't be blank"
  # end

  # test "should be invalid without surname" do
  #   @legal_guardian.surname = nil
  #   assert_not @legal_guardian.valid?
  #   assert_includes @legal_guardian.errors[:surname], "can't be blank"
  # end

  # test "should be invalid without email" do
  #   @legal_guardian.email = nil
  #   assert_not @legal_guardian.valid?
  #   assert_includes @legal_guardian.errors[:email], "can't be blank"
  # end

  # test "should be invalid without phone" do
  #   @legal_guardian.phone = nil
  #   assert_not @legal_guardian.valid?
  #   assert_includes @legal_guardian.errors[:phone], "can't be blank"
  # end

  # test "should be invalid without date_of_birth" do
  #   @legal_guardian.date_of_birth = nil
  #   assert_not @legal_guardian.valid?
  #   assert_includes @legal_guardian.errors[:date_of_birth], "can't be blank"
  # end

  # test "should have many users" do
  #   assert_respond_to @legal_guardian, :users
  # end
end
