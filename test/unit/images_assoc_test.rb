require 'test_helper'

class ImagesAssociationsTest < ActiveSupport::TestCase

  should 'properly link images with one species' do
    sp = Species.find_by_code!('lancol')
    obs = Factory.create(:observation, :species => sp, :observ_date => "2008-06-20")
    obs.images << img = Factory.create(:image, :code => 'Picture of the Shrike')

    assert_equal [img.code], sp.images.map(&:code)
    assert_equal [sp.code], img.species.map(&:code)
  end

  should 'properly link images with several species' do
    sp1 = Species.find_by_code!('lancol')
    sp2 = Species.find_by_code!('jyntor')
    obs1 = Factory.create(:observation, :species => sp1, :observ_date => "2008-07-01")
    obs2 = Factory.create(:observation, :species => sp2, :observ_date => "2008-07-01")
    img = Factory.create(:image, :code => 'Picture of the Shrike and the Wryneck')
    img.observations << obs1 << obs2

    assert_equal [img.code], sp1.images.map(&:code)
    assert_equal [img.code], sp2.images.map(&:code)
    assert_equal [sp1.code, sp2.code], img.species.map(&:code)
  end


end