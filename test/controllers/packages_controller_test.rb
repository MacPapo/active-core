require "test_helper"

class PackagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @package = packages(:beginner_package)
    @product = products(:pilates_class)
    sign_in @admin_user
  end

  test "should get index" do
    get packages_url
    assert_response :success
  end

  test "should get new" do
    get new_package_url
    assert_response :success
  end

  test "should create package" do
    assert_difference("Package.count") do
      post packages_url, params: {
             package: {
               name: "Test Package",
               description: "Test description",
               price: 99.99,
               duration_type: "months",
               duration_value: 3,
               active: true
             }
           }
    end

    assert_redirected_to package_url(Package.last)
  end

  test "should create package with inclusions" do
    assert_difference([ "Package.count", "PackageInclusion.count" ]) do
      post packages_url, params: {
             package: {
               name: "Package with Inclusions",
               price: 150.00,
               duration_type: "months",
               duration_value: 6,
               active: true,
               package_inclusions_attributes: {
                 "0" => {
                   product_id: @product.id,
                   access_type: "limited_sessions",
                   session_limit: 10
                 }
               }
             }
           }
    end

    package = Package.last
    assert_equal 1, package.package_inclusions.count
    assert_redirected_to package_url(package)
  end

  test "should show package" do
    get package_url(@package)
    assert_response :success
  end

  test "should get edit" do
    get edit_package_url(@package)
    assert_response :success
  end

  test "should update package" do
    patch package_url(@package), params: {
            package: { name: "Updated Package Name" }
          }
    assert_redirected_to package_url(@package)
    assert_equal "Updated Package Name", @package.reload.name
  end

  test "should destroy package" do
    delete package_url(@package)
    assert_redirected_to packages_url
    assert @package.reload.discarded?
  end

  test "should not create package without name" do
    assert_no_difference("Package.count") do
      post packages_url, params: {
             package: {
               price: 99.99,
               duration_type: "months",
               duration_value: 3
             }
           }
    end

    assert_response :unprocessable_content
  end
end
