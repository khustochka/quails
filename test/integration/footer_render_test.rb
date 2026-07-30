# frozen_string_literal: true

require "test_helper"

class FooterRenderTest < ActionDispatch::IntegrationTest
  test "picks the footer links partial for the current locale" do
    get lists_overview_path
    assert_select ".footer-links a", text: I18n.t("menu.english", locale: :uk)
    assert_select ".footer-links a", text: I18n.t("menu.ukrainian", locale: :uk), count: 0

    get lists_overview_path(locale: :en)
    assert_select ".footer-links a", text: I18n.t("menu.ukrainian", locale: :en)
    assert_select ".footer-links a", text: I18n.t("menu.english", locale: :en), count: 0
  end

  test "renders the same footer under the legacy application layout" do
    get blog_path
    assert_response :success

    assert_select "footer.page_footer .footer-links .footer-column", 4
    assert_select ".footer-text .footer-attribution"
    assert_select ".footer-text .footer-license"
  end

  test "omits footer links but keeps attribution where hide_footer_links? applies" do
    get map_path
    assert_response :success

    assert_select ".footer-links", false
    assert_select ".footer-text .footer-attribution"
    assert_select ".footer-text .footer-license"
  end
end
