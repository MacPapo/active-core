require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
    @product = products(:pilates_class)
  end

  test "should get index without authentication" do
    sign_in @regular_user
    get products_url, headers: { "Accept" => "text/html" }
    assert_response :success
  end

  test "should show product without authentication" do
    sign_in @regular_user
    get product_url(@product)
    assert_response :success
  end

  test "should filter by product type" do
    sign_in @regular_user
    get products_url, params: { product_type: "course" }
    assert_response :success
  end

  test "should get new as admin" do
    sign_in @admin_user
    get new_product_url
    assert_response :success
  end

  test "should not get new as regular user" do
    sign_in @regular_user
    get new_product_url
    assert_response :redirect
  end

  test "should create product as admin" do
    sign_in @admin_user
    assert_difference "Product.count" do
      post products_url, params: {
             product: {
               name: "Pilates Avanzato",
               product_type: "course",
               description: "Corso di pilates livello avanzato",
               capacity: 15,
               requires_membership: true,
               active: true
             }
           }
    end

    product = Product.last
    assert_redirected_to product_url(product)
    follow_redirect!
    assert_select ".notice", "Prodotto creato con successo!"
  end

  test "should not create product as regular user" do
    sign_in @regular_user
    assert_no_difference "Product.count" do
      post products_url, params: {
             product: { name: "Test", product_type: "course" }
           }
    end
    assert_response :redirect
  end
end
