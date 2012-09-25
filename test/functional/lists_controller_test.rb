require 'test_helper'

class ListsControllerTest < ActionController::TestCase

  setup do
    @obs = [
        create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york)),
        create(:observation, species: seed(:melgal), observ_date: "2010-06-18", locus: seed(:new_york)),
        create(:observation, species: seed(:anapla), observ_date: "2009-06-18", locus: seed(:new_york)),
        create(:observation, species: seed(:anacly), observ_date: "2007-07-18"),
        create(:observation, species: seed(:embcit), observ_date: "2009-08-09", locus: seed(:kherson))
    ]
  end

  test 'get index' do
    get :index
    assert_response :success
  end

end
