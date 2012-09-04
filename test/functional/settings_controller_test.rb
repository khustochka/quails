# encoding: utf-8

require 'test_helper'

class SettingsControllerTest < ActionController::TestCase

  test "admin can see settings" do
    login_as_admin
    get :index
    assert_template 'index'
    assert_kind_of Hash, assigns(:settings)
  end

  test "create new setting" do
    login_as_admin
    post :save, {new_setting: 'this value', utf8: '✓'}
    assert_equal 'this value', Settings.find_by_key(:new_setting).value
    assert_empty Settings.where(key: [:utf8, :authenticity_token, :controller, :action]), "Bad keys are saved"
  end

  test "update existing setting" do
    login_as_admin
    Settings.create(key: 'old_setting', value: 'old value')
    post :save, {old_setting: 'new value'}
    assert_equal 'new value', Settings.find_by_key(:old_setting).value
  end

end
