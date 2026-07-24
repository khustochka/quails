# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionController::TestCase
  test "shows the about page" do
    get :show, params: { id: "about" }

    assert_response :success
    assert assigns(:localized)
    assert_equal Quails.enabled_locales, assigns(:all_locales)
  end

  test "no English translation for the Links page" do
    get :show, params: { id: "links" }

    assert_response :success
    assert_not_includes assigns(:all_locales), :en
  end

  test "no English translation for the Winter page" do
    get :show, params: { id: "winter" }

    assert_response :success
    assert assigns(:localized)
    assert_not_includes assigns(:all_locales), :en
  end
end
