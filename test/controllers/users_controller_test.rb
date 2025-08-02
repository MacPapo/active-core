require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @collaborator = users(:collaborator_user)
    @user = users(:staff_user)
    @member_without_user = members(:available_member)
  end

  # Authentication tests
  test "should redirect to login when not authenticated" do
    get users_path
    assert_redirected_to new_user_session_path
  end

  test "should deny access to non-admin users" do
    sign_in @collaborator
    get users_path
    assert_redirected_to root_path
    assert_equal "Accesso negato. Privilegi amministratore richiesti.", flash[:alert]
  end

  # INDEX tests
  test "should get index as admin" do
    sign_in @admin
    get users_path
    assert_response :success
  end

  test "should filter users by role" do
    sign_in @admin
    get users_path, params: { role: :admin }
    assert_response :success
  end

  test "should search users by name" do
    sign_in @admin
    get users_path, params: { search: @user.member.name }
    assert_response :success
  end

  test "should sort users by nickname" do
    sign_in @admin
    get users_path, params: { sort_by: "nickname", direction: "asc" }
    assert_response :success
  end

  # SHOW tests
  test "should show user" do
    sign_in @admin
    get user_path(@user)
    assert_response :success
    assert_select "h1", @user.nickname
  end

  test "should display user statistics" do
    sign_in @admin
    get user_path(@user)
    assert_response :success
  end

  # NEW tests
  test "should get new" do
    sign_in @admin
    get new_user_path
    assert_response :success
    assert_select "form[action=?]", users_path
  end

  test "should show available members in new form" do
    sign_in @admin
    get new_user_path
    assert_response :success
    assert_select "select[name='user[member_id]'] option", count: Member.kept.left_joins(:user).where(users: { id: nil }).count + 1
  end

  # CREATE tests
  test "should create user with valid params" do
    sign_in @admin

    assert_difference("User.count") do
      post users_path, params: {
             user: {
               nickname: "new_staff",
               member_id: @member_without_user.id,
               role: :collaborator,
               password: "password123",
               password_confirmation: "password123"
             }
           }
    end

    assert_redirected_to user_path(User.last)
    assert_equal "Utente staff creato con successo.", flash[:notice]
  end

  test "should not create user with invalid params" do
    sign_in @admin

    assert_no_difference("User.count") do
      post users_path, params: {
             user: {
               nickname: "", # Invalid
               member_id: @member_without_user.id,
               role: :collaborator
             }
           }
    end

    assert_response :unprocessable_entity
    assert_select ".field_with_errors"
  end

  test "should not create user without member" do
    sign_in @admin

    assert_no_difference("User.count") do
      post users_path, params: {
             user: {
               nickname: "test_user",
               role: :collaborator,
               password: "password123",
               password_confirmation: "password123"
             }
           }
    end

    assert_response :unprocessable_entity
  end

  # EDIT tests
  test "should get edit" do
    sign_in @admin
    get edit_user_path(@user)
    assert_response :success
    assert_select "form[action=?]", user_path(@user)
  end

  # UPDATE tests
  test "should update user" do
    sign_in @admin
    patch user_path(@user), params: {
            user: { nickname: "updated_nickname" }
          }

    assert_redirected_to user_path(@user)
    assert_equal "Utente aggiornato con successo.", flash[:notice]
    @user.reload
    assert_equal "updated_nickname", @user.nickname
  end

  test "should not update user with invalid params" do
    sign_in @admin
    patch user_path(@user), params: {
            user: { nickname: "" }
          }

    assert_response :unprocessable_entity
    assert_select ".field_with_errors"
  end

  test "should update user role" do
    sign_in @admin
    patch user_path(@user), params: {
            user: { role: :admin }
          }

    assert_redirected_to user_path(@user)
    @user.reload
    assert_equal "admin", @user.role
  end

  # DESTROY tests
  test "should destroy user" do
    sign_in @admin

    assert_difference("User.kept.count", -1) do
      delete user_path(@user)
    end

    assert_redirected_to users_path
    assert_equal "Utente eliminato con successo.", flash[:notice]
    assert @user.reload.discarded?
  end
end
