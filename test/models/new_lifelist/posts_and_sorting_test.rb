require 'test_helper'

module NewLifelist

  class PostsAndSortingTest < ActiveSupport::TestCase

    test 'Properly associate card post with lifer' do
      post = FactoryGirl.create(:post)
      card = FactoryGirl.create(:card, post: post)
      obs = FactoryGirl.create(:observation, card: card)
      list = NewLifelist::FirstSeen.full
      list.set_posts_scope(Post.public_posts)
      assert_equal post, list.first.main_post
    end

    test 'Properly associate observation post with lifer' do
      post = FactoryGirl.create(:post)
      obs = FactoryGirl.create(:observation, post: post)
      list = NewLifelist::FirstSeen.full
      list.set_posts_scope(Post.public_posts)
      assert_equal post, list.first.main_post
    end

    test "should not include hidden posts (from observation)" do
      post = FactoryGirl.create(:post, status: "PRIV")
      obs = FactoryGirl.create(:observation, post: post)
      list = NewLifelist::FirstSeen.full
      list.set_posts_scope(Post.public_posts)
      assert_equal nil, list.first.main_post
    end

    test "should not include hidden posts (from card)" do
      post = FactoryGirl.create(:post, status: "PRIV")
      card = FactoryGirl.create(:card, post: post)
      obs = FactoryGirl.create(:observation, card: card)
      list = NewLifelist::FirstSeen.full
      list.set_posts_scope(Post.public_posts)
      assert_equal nil, list.first.main_post
    end

    test "should take into account start time when ordering lifers (diff species)" do
      card1 = FactoryGirl.create(:card, start_time: "9:00")
      card2 = FactoryGirl.create(:card, start_time: "13:00")
      obs1 = FactoryGirl.create(:observation, card: card1, species: seed("pasdom"))
      obs2 = FactoryGirl.create(:observation, card: card2, species: seed("colliv"))
      list = NewLifelist::FirstSeen.full.to_a
      # First is the newer (seen later)
      assert_equal "colliv", list.first.species.code
      # Last is the older (seen earlier)
      assert_equal "pasdom", list.last.species.code
    end

    test "should treat start time as earlier when ordering different lifers" do
      card1 = FactoryGirl.create(:card, start_time: nil)
      card2 = FactoryGirl.create(:card, start_time: "13:00")
      obs1 = FactoryGirl.create(:observation, card: card1, species: seed("pasdom"))
      obs2 = FactoryGirl.create(:observation, card: card2, species: seed("colliv"))
      list = NewLifelist::FirstSeen.full.to_a
      # First is the newer (seen later)
      assert_equal "colliv", list.first.species.code
      # Last is the older (seen earlier)
      assert_equal "pasdom", list.last.species.code
    end

    # Sometimes a lifer is seen several times a day. Correct first card should be selected
    test "should take into account start time when selecting lifer card (same species)" do
      card1 = FactoryGirl.create(:card, start_time: "13:00")
      card2 = FactoryGirl.create(:card, start_time: "9:00")
      obs1 = FactoryGirl.create(:observation, card: card1, species: seed("nycsca"))
      obs2 = FactoryGirl.create(:observation, card: card2, species: seed("nycsca"))
      list = NewLifelist::FirstSeen.full.to_a
      # Lifer should be the earlier observation
      assert_equal "9:00", list.first.card.start_time
    end

    test "for lifer card empty start time is lower priority" do
      card1 = FactoryGirl.create(:card, start_time: "9:00")
      card2 = FactoryGirl.create(:card, start_time: nil)
      obs1 = FactoryGirl.create(:observation, card: card1, species: seed("nycsca"))
      obs2 = FactoryGirl.create(:observation, card: card2, species: seed("nycsca"))
      list = NewLifelist::FirstSeen.full.to_a
      assert_equal "9:00", list.first.card.start_time
    end

  end
end
