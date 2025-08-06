require "test_helper"

class AccessGrantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @access_grant = access_grants(:one)
  end

  test "should get index" do
    get access_grants_url
    assert_response :success
  end

  test "should get new" do
    get new_access_grant_url
    assert_response :success
  end

  test "should create access_grant" do
    assert_difference("AccessGrant.count") do
      post access_grants_url, params: { access_grant: {} }
    end

    assert_redirected_to access_grant_url(AccessGrant.last)
  end

  test "should show access_grant" do
    get access_grant_url(@access_grant)
    assert_response :success
  end

  test "should get edit" do
    get edit_access_grant_url(@access_grant)
    assert_response :success
  end

  test "should update access_grant" do
    patch access_grant_url(@access_grant), params: { access_grant: {} }
    assert_redirected_to access_grant_url(@access_grant)
  end

  test "should destroy access_grant" do
    assert_difference("AccessGrant.count", -1) do
      delete access_grant_url(@access_grant)
    end

    assert_redirected_to access_grants_url
  end
end
