# frozen_string_literal: true

require "test_helper"

class LogbookSettingsControllerTest < ActionController::TestCase
  test "user cannot see logbook settings" do
    assert_raise(ActionController::RoutingError) { get :show }
  end

  test "admin sees logbook settings" do
    create(:observation, card: create(:card, locus: loci(:brovary)))
    LogbookSetting.create!(locus: loci(:ukraine), year: true)

    login_as_admin
    get :show

    assert_response :success
    assert_select ".admin-shortcuts a[href='/settings']"
    assert_select "input[type=checkbox][name='settings[world][life]']"
    assert_select "input[type=checkbox][name='settings[#{loci(:ukraine).id}][year]'][checked]"
    assert_select "input[type=checkbox][name='settings[#{loci(:ukraine).id}][life]']:not([checked])"
  end

  test "admin saves logbook settings" do
    ukraine = loci(:ukraine)
    login_as_admin
    patch :update, params: { settings: {
      world: { life: "1", year: "0" },
      ukraine.id.to_s => { life: "0", year: "1" },
    } }

    assert_redirected_to logbook_settings_path
    assert_equal [[nil, true, false], [ukraine.id, false, true]],
      LogbookSetting.order(Arel.sql("locus_id NULLS FIRST")).pluck(:locus_id, :life, :year)
  end
end
