# frozen_string_literal: true

require "test_helper"

module Lifelist

  class PostsAndSortingTest < ActiveSupport::TestCase

    test "Properly associate card post with lifer" do
      post = FactoryBot.create(:post)
      card = FactoryBot.create(:card, post: post)
      obs = FactoryBot.create(:observation, card: card)
      list = Lifelist::FirstSeen.full
      list.set_posts_scope(Post.public_posts)
      assert_equal post, list.first.main_post
    end

    test "Properly associate observation post with lifer" do
      post = FactoryBot.create(:post)
      obs = FactoryBot.create(:observation, post: post)
      list = Lifelist::FirstSeen.full
      list.set_posts_scope(Post.public_posts)
      assert_equal post, list.first.main_post
    end

    test "should not include hidden posts (from observation)" do
      post = FactoryBot.create(:post, status: "PRIV")
      obs = FactoryBot.create(:observation, post: post)
      list = Lifelist::FirstSeen.full
      list.set_posts_scope(Post.public_posts)
      assert_nil list.first.main_post
    end

    test "should not include hidden posts (from card)" do
      post = FactoryBot.create(:post, status: "PRIV")
      card = FactoryBot.create(:card, post: post)
      obs = FactoryBot.create(:observation, card: card)
      list = Lifelist::FirstSeen.full
      list.set_posts_scope(Post.public_posts)
      assert_nil list.first.main_post
    end

    test "should take into account start time when ordering lifers (diff species)" do
      card1 = FactoryBot.create(:card, start_time: "9:00")
      card2 = FactoryBot.create(:card, start_time: "13:00")
      obs1 = FactoryBot.create(:observation, card: card1, taxon: taxa("pasdom"))
      obs2 = FactoryBot.create(:observation, card: card2, taxon: taxa("hirrus"))
      list = Lifelist::FirstSeen.full.to_a
      # First is the newer (seen later)
      assert_equal "hirrus", list.first.species.code
      # Last is the older (seen earlier)
      assert_equal "pasdom", list.last.species.code
    end

    test "should treat start time as earlier when ordering different lifers" do
      card1 = FactoryBot.create(:card, start_time: nil)
      card2 = FactoryBot.create(:card, start_time: "13:00")
      obs1 = FactoryBot.create(:observation, card: card1, taxon: taxa("pasdom"))
      obs2 = FactoryBot.create(:observation, card: card2, taxon: taxa("hirrus"))
      list = Lifelist::FirstSeen.full.to_a
      # First is the newer (seen later)
      assert_equal "hirrus", list.first.species.code
      # Last is the older (seen earlier)
      assert_equal "pasdom", list.last.species.code
    end

    # Sometimes a lifer is seen several times a day. Correct first card should be selected
    test "should take into account start time when selecting lifer card (same species)" do
      card1 = FactoryBot.create(:card, start_time: "13:00")
      card2 = FactoryBot.create(:card, start_time: "9:00")
      obs1 = FactoryBot.create(:observation, card: card1, taxon: taxa("jyntor"))
      obs2 = FactoryBot.create(:observation, card: card2, taxon: taxa("jyntor"))
      list = Lifelist::FirstSeen.full.to_a
      # Lifer should be the earlier observation
      assert_equal "9:00", list.first.card.start_time
    end

    test "for lifer card empty start time is lower priority" do
      card1 = FactoryBot.create(:card, start_time: "9:00")
      card2 = FactoryBot.create(:card, start_time: nil)
      obs1 = FactoryBot.create(:observation, card: card1, taxon: taxa("jyntor"))
      obs2 = FactoryBot.create(:observation, card: card2, taxon: taxa("jyntor"))
      list = Lifelist::FirstSeen.full.to_a
      assert_equal "9:00", list.first.card.start_time
    end

  end
end
