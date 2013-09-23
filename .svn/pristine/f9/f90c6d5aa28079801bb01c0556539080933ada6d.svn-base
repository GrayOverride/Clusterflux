require 'test_helper'

class Admin::UpdatesControllerTest < ActionController::TestCase
  setup do
    @admin_update = admin_updates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_updates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_update" do
    assert_difference('Admin::Update.count') do
      post :create, admin_update: { desc: @admin_update.desc, title: @admin_update.title }
    end

    assert_redirected_to admin_update_path(assigns(:admin_update))
  end

  test "should show admin_update" do
    get :show, id: @admin_update
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_update
    assert_response :success
  end

  test "should update admin_update" do
    put :update, id: @admin_update, admin_update: { desc: @admin_update.desc, title: @admin_update.title }
    assert_redirected_to admin_update_path(assigns(:admin_update))
  end

  test "should destroy admin_update" do
    assert_difference('Admin::Update.count', -1) do
      delete :destroy, id: @admin_update
    end

    assert_redirected_to admin_updates_path
  end
end
