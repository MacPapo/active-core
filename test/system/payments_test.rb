require "application_system_test_case"

class PaymentsTest < ApplicationSystemTestCase
  setup do
    @payment = payments(:one)
  end

  test "visiting the index" do
    visit payments_url
    assert_selector "h1", text: "Payments"
  end

  test "should create payment" do
    visit payments_url
    click_on "New payment"

    fill_in "Amount", with: @payment.amount
    fill_in "Date", with: @payment.date
    fill_in "Entry type", with: @payment.entry_type
    fill_in "Method", with: @payment.method
    fill_in "Note", with: @payment.note
    fill_in "Payment type", with: @payment.payment_type
    fill_in "Staff", with: @payment.staff_id
    fill_in "State", with: @payment.state
    fill_in "Subscription", with: @payment.subscription_id
    click_on "Create Payment"

    assert_text "Payment was successfully created"
    click_on "Back"
  end

  test "should update Payment" do
    visit payment_url(@payment)
    click_on "Edit this payment", match: :first

    fill_in "Amount", with: @payment.amount
    fill_in "Date", with: @payment.date
    fill_in "Entry type", with: @payment.entry_type
    fill_in "Method", with: @payment.method
    fill_in "Note", with: @payment.note
    fill_in "Payment type", with: @payment.payment_type
    fill_in "Staff", with: @payment.staff_id
    fill_in "State", with: @payment.state
    fill_in "Subscription", with: @payment.subscription_id
    click_on "Update Payment"

    assert_text "Payment was successfully updated"
    click_on "Back"
  end

  test "should destroy Payment" do
    visit payment_url(@payment)
    click_on "Destroy this payment", match: :first

    assert_text "Payment was successfully destroyed"
  end
end
