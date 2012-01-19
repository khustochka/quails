require 'test_helper'

class ImagesAssociationsTest < ActiveSupport::TestCase

  setup do
    @obs = FactoryGirl.create(:observation)
    @image = FactoryGirl.create(:image, observations: [@obs])
  end

  test 'properly link images with one species' do
    sp = @obs.species

    assert_equal [@image.code], sp.images.map(&:code)
    assert_equal [sp.code], @image.species.map(&:code)
  end

  test 'properly link images with several species' do
    sp1 = seed(:lancol)
    sp2 = seed(:jyntor)
    obs1 = FactoryGirl.create(:observation, species: sp1, observ_date: "2008-07-01")
    obs2 = FactoryGirl.create(:observation, species: sp2, observ_date: "2008-07-01")
    img = FactoryGirl.create(:image, code: 'picture-of-the-shrike-and-the-wryneck', observations: [obs1, obs2])

    assert_equal [img.code], sp1.images.map(&:code)
    assert_equal [img.code], sp2.images.map(&:code)
    ([sp1.code, sp2.code] - img.species.map(&:code)).should be_empty
  end

  test 'properly link image and post' do
    blogpost = FactoryGirl.create(:post, observations: [@obs])

    assert_equal [@image.code], blogpost.images.map(&:code)
    assert_equal blogpost.code, @image.post.code
  end

  test 'properly unlink observations when image destroyed' do
    @image.destroy
    assert @obs.reload
    assert_equal 0, @obs.images.size
  end


end