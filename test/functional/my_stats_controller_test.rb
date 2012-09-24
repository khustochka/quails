require 'test_helper'

class MyStatsControllerTest < ActionController::TestCase
  setup do
    create(:observation, species: seed(:pasdom), observ_date: "2011-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2012-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2012-06-18")
    create(:observation, species: seed(:anacly), observ_date: "2012-07-18", locus: seed(:brovary))
    create(:observation, species: seed(:embcit), observ_date: "2011-08-09", locus: seed(:kherson))
  end

  test 'shows My Statistics page' do
    get :index
  end

end
