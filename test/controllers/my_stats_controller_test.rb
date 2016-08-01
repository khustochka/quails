require 'test_helper'

class MyStatsControllerTest < ActionController::TestCase
  setup do
    create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2011-06-20", locus: loci(:nyc)))
    create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2012-06-18"))
    create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2012-06-18"))
    create(:observation, taxon: taxa(:lancol), card: create(:card, observ_date: "2012-07-18", locus: loci(:brovary)))
    create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2011-08-09", locus: loci(:kiev)))
  end

  test 'shows My Statistics page' do
    get :index
  end

end
