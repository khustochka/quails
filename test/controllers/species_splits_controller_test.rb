# frozen_string_literal: true

require "test_helper"

class SpeciesSplitsControllerTest < ActionController::TestCase
  test "user does not see the splits page" do
    assert_raise(ActionController::RoutingError) { get :index }
  end

  test "admin sees the splits page when there are none" do
    login_as_admin
    get :index

    assert_response :success
    assert_empty assigns(:splits)
  end

  test "admin sees a split with both species named" do
    SpeciesSplit.create!(superspecies: species(:saxola), subspecies: species(:pasdom))

    login_as_admin
    get :index

    assert_response :success
    assert_select "td", text: /Saxicola rubicola/
    assert_select "td", text: /Passer domesticus/
  end

  test "splits are ordered by the scientific name of the superspecies" do
    SpeciesSplit.create!(superspecies: species(:saxola), subspecies: species(:pasdom))
    SpeciesSplit.create!(superspecies: species(:bomgar), subspecies: species(:hirrus))

    login_as_admin
    get :index

    assert_response :success
    assert_equal ["Bombycilla garrulus", "Saxicola rubicola"], assigns(:splits).map { |s| s.superspecies.name_sci }
  end
end
