require 'test_helper'

class ListsControllerTest < ActionController::TestCase

  setup do
    @obs = [
        create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc))),
        create(:observation, species: seed(:melgal), card: create(:card, observ_date: "2010-06-18", locus: loci(:nyc))),
        create(:observation, species: seed(:anapla), card: create(:card, observ_date: "2009-06-18", locus: loci(:nyc))),
        create(:observation, species: seed(:anacly), card: create(:card, observ_date: "2007-07-18")),
        create(:observation, species: seed(:embcit), card: create(:card, observ_date: "2009-08-09", locus: loci(:kiev)))
    ]
  end

  test 'get index' do
    %w(united_kingdom canada).each do |sl|
      create(:locus, slug: sl, loc_type: "country")
    end
    get :index
    assert_response :success
  end

end
