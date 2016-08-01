require 'test_helper'

class ListsControllerTest < ActionController::TestCase

  setup do
    @obs = [
        create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc))),
        create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2010-06-18", locus: loci(:nyc))),
        create(:observation, taxon: taxa(:bomgar), card: create(:card, observ_date: "2009-06-18", locus: loci(:nyc))),
        create(:observation, taxon: taxa(:lancol), card: create(:card, observ_date: "2007-07-18")),
        create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2009-08-09", locus: loci(:kiev)))
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
