require 'test_helper'

class ImagesAssociationsTest < ActiveSupport::TestCase

  test 'properly link images with one species' do
    sp = seed(:lancol)
    obs = FactoryGirl.create(:observation, :species => sp, :observ_date => "2008-06-20")
    img = FactoryGirl.build(:image, :code => 'picture-of-the-shrike')
    img.observations << obs
    img.save

    assert_equal [img.code], sp.images.map(&:code)
    assert_equal [sp.code], img.species.map(&:code)
  end

  test 'properly link images with several species' do
    sp1 = seed(:lancol)
    sp2 = seed(:jyntor)
    obs1 = FactoryGirl.create(:observation, :species => sp1, :observ_date => "2008-07-01")
    obs2 = FactoryGirl.create(:observation, :species => sp2, :observ_date => "2008-07-01")
    img = FactoryGirl.build(:image, :code => 'picture-of-the-shrike-and-the-wryneck')
    img.observations << obs1 << obs2
    img.save

    assert_equal [img.code], sp1.images.map(&:code)
    assert_equal [img.code], sp2.images.map(&:code)
    ([sp1.code, sp2.code] - img.species.map(&:code)).should be_empty
  end

  test 'properly link image and post' do
    sp = seed(:lancol)
    blogpost = FactoryGirl.create(:post)
    obs = FactoryGirl.create(:observation, :species => sp, :observ_date => "2008-06-20")
    blogpost.observations << obs
    img = FactoryGirl.build(:image, :code => 'picture-of-the-shrike')
    img.observations << obs
    img.save

    assert_equal [img.code], blogpost.images.map(&:code)
    assert_equal blogpost.code, img.post.code
  end

  test 'properly unlink observations when image destroyed' do
    observation = FactoryGirl.create(:observation)
    img = FactoryGirl.build(:image, :code => 'picture-of-the-shrike')
    img.observations << observation
    img.save
    assert_nothing_raised do
      img.destroy
    end
    assert observation.reload
    assert_equal 0, observation.images.size
  end


end