# frozen_string_literal: true

require "test_helper"

class HeaderRenderTest < ActionDispatch::IntegrationTest
  test "renders locale-specific menu for each supported locale" do
    get blog_path
    assert_response :success
    assert_select "a", text: I18n.t("menu.blog", locale: :uk)

    get blog_path(locale: :en)
    assert_response :success
    assert_select "a", text: I18n.t("menu.home", locale: :en)

    get blog_path(locale: :ru)
    assert_response :success
    assert_select "a", text: I18n.t("menu.blog", locale: :ru)
  end
end
