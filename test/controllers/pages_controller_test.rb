# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionController::TestCase
  test "shows the about page" do
    get :show, params: { id: "about" }

    assert_response :success
    assert assigns(:localized)
    assert_equal I18n.available_locales, assigns(:all_locales)
  end

  test "shows the links page in Russian" do
    get :show, params: { id: "links", locale: "ru" }

    assert_response :success
    assert_equal [:uk, :ru], assigns(:all_locales)
  end

  test "the winter page is marked as localized but not translated" do
    get :show, params: { id: "winter", locale: "ru" }

    assert_response :success
    assert assigns(:localized)
    assert_empty assigns(:all_locales)
  end
end
