require 'test_helper'

class NewLifelistTest < ActiveSupport::TestCase

  test "should not include hidden posts (from observation)" do
    post = FactoryGirl.create(:post, status: "PRIV")
    obs = FactoryGirl.create(:observation, post: post)
    list = NewLifelist.full.to_a
    assert_equal nil, list.first.main_post
  end

  test "should not include hidden posts (from card)" do
    post = FactoryGirl.create(:post, status: "PRIV")
    card = FactoryGirl.create(:card, post: post)
    obs = FactoryGirl.create(:observation, card: card)
    list = NewLifelist.full.to_a
    assert_equal nil, list.first.main_post
  end

end
