require 'test_helper'

class MyStatsControllerTest < ActionController::TestCase
  setup do
    create(:observation, species: species(:pasdom), card: create(:card, observ_date: "2011-06-20", locus: loci(:nyc)))
    create(:observation, species: species(:melgal), card: create(:card, observ_date: "2012-06-18"))
    create(:observation, species: species(:anapla), card: create(:card, observ_date: "2012-06-18"))
    create(:observation, species: species(:anacly), card: create(:card, observ_date: "2012-07-18", locus: loci(:brovary)))
    create(:observation, species: species(:embcit), card: create(:card, observ_date: "2011-08-09", locus: loci(:kiev)))
  end

  test 'shows My Statistics page' do
    get :index
  end

end
