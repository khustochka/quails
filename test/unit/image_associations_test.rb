require 'test_helper'

class ImagesAssociationsTest < ActiveSupport::TestCase

  test 'properly link images with one species' do
    sp = seed(:lancol)
    obs = FactoryGirl.create(:observation, :species => sp)
    img = FactoryGirl.create(:image, :code => 'picture-of-the-shrike', :observations => [obs])

    assert_equal [img.code], sp.images.map(&:code)
    assert_equal [sp.code], img.species.map(&:code)
  end

  test 'properly link images with several species' do
    sp1 = seed(:lancol)
    sp2 = seed(:jyntor)
    obs1 = FactoryGirl.create(:observation, :species => sp1, :observ_date => "2008-07-01")
    obs2 = FactoryGirl.create(:observation, :species => sp2, :observ_date => "2008-07-01")
    img = FactoryGirl.create(:image, :code => 'picture-of-the-shrike-and-the-wryneck', :observations => [obs1, obs2])

    assert_equal [img.code], sp1.images.reload.map(&:code)
    assert_equal [img.code], sp2.images.reload.map(&:code)
    ([sp1.code, sp2.code] - img.species.map(&:code)).should be_empty
  end

  test 'properly link image and post' do
    sp = seed(:lancol)
    obs = FactoryGirl.create(:observation, :species => sp)
    blogpost = FactoryGirl.create(:post, :observations => [obs])
    img = FactoryGirl.create(:image, :code => 'picture-of-the-shrike', :observations => [obs])

    assert_equal [img.code], blogpost.images.map(&:code)
    assert_equal blogpost.code, img.post.code
  end

  test 'properly unlink observations when image destroyed' do
    observation = FactoryGirl.create(:observation)
    img = FactoryGirl.create(:image, :code => 'picture-of-the-shrike', :observations => [observation])
    assert_nothing_raised do
      img.destroy
    end
    assert observation.reload
    assert_equal 0, observation.images.size
  end


end