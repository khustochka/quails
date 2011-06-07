require 'test_helper'

class ImagesAssociationsTest < ActiveSupport::TestCase

  should 'properly link images with one species' do
    sp = Species.find_by_code!('lancol')
    obs = Factory.create(:observation, :species => sp, :observ_date => "2008-06-20")
    img = Factory.build(:image, :code => 'picture-of-the-shrike')
    img.observations << obs
    img.save

    assert_equal [img.code], sp.images.map(&:code)
    assert_equal [sp.code], img.species.map(&:code)
  end

  should 'properly link images with several species' do
    sp1 = Species.find_by_code!('lancol')
    sp2 = Species.find_by_code!('jyntor')
    obs1 = Factory.create(:observation, :species => sp1, :observ_date => "2008-07-01")
    obs2 = Factory.create(:observation, :species => sp2, :observ_date => "2008-07-01")
    img = Factory.build(:image, :code => 'picture-of-the-shrike-and-the-wryneck')
    img.observations << obs1 << obs2
    img.save

    assert_equal [img.code], sp1.images.map(&:code)
    assert_equal [img.code], sp2.images.map(&:code)
    assert_equal [sp1.code, sp2.code], img.species.map(&:code)
  end

  should 'properly link image and post' do
    sp = Species.find_by_code!('lancol')
    blogpost = Factory.create(:post)
    obs = Factory.create(:observation, :species => sp, :observ_date => "2008-06-20")
    blogpost.observations << obs
    img = Factory.build(:image, :code => 'picture-of-the-shrike')
    img.observations << obs
    img.save

    assert_equal [img.code], blogpost.images.map(&:code)
    assert_equal blogpost.code, img.post.code
  end


end