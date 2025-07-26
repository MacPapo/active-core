require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @collaborator_user = users(:collaborator_user)
    @payment = payments(:membership_payment)
    sign_in @admin_user
  end

  test "should get index as admin" do
    get payments_url
    assert_response :success
  end

  test "should deny access to collaborator" do
    sign_in @collaborator_user
    get payments_url
    assert_redirected_to root_path
  end

  test "should get new" do
    get new_payment_url
    assert_response :success
  end

  test "should create payment" do
    assert_difference("Payment.count") do
      post payments_url, params: {
             payment: {
               date: Date.current,
               income: true,
               payment_method: "cash",
               notes: "Test payment",
               payment_items_attributes: {
                 "0" => { amount: 50.0, description: "Test item" }
               }
             }
           }
    end

    assert_redirected_to payment_url(Payment.last)
  end

  test "should show payment" do
    get payment_url(@payment)
    assert_response :success
  end

  test "should not create payment without items" do
    assert_no_difference("Payment.count") do
      post payments_url, params: {
             payment: {
               date: Date.current,
               income: true,
               payment_method: "cash"
             }
           }
    end

    assert_response :unprocessable_content
  end
end
