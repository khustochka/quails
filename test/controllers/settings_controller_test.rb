# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionController::TestCase
  test "admin can see settings" do
    login_as_admin
    get :index
    assert_template "index"
  end

  test "create new setting" do
    login_as_admin
    post :save, params: {s: {new_setting: "this value"}}
    assert_equal "this value", Settings.find_by(key: :new_setting).value
  end

  test "update existing setting" do
    login_as_admin
    Settings.create(key: "old_setting", value: "old value")
    post :save, params: {s: {old_setting: "new value"}}
    assert_equal "new value", Settings.find_by(key: :old_setting).value
  end
end
