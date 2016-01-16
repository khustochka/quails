require 'test_helper'

module Lifelist

  class AdvancedTest < ActiveSupport::TestCase

    test "it should have species" do

      obs = FactoryGirl.create(:observation)

      list = Lifelist::Advanced.over({}).sort(nil)

      assert_equal obs.species, list.to_a.first.species

    end

    test "it should have first seen observation" do

      obs = FactoryGirl.create(:observation)
      obs2 = FactoryGirl.create(:observation, card: FactoryGirl.create(:card, observ_date: obs.card.observ_date + 1.day))

      list = Lifelist::Advanced.over({}).sort(nil)

      assert_equal obs.id, list.to_a.first.first_seen.id

    end

    test "it should return last seen observation" do

      obs = FactoryGirl.create(:observation)
      obs2 = FactoryGirl.create(:observation, card: FactoryGirl.create(:card, observ_date: obs.card.observ_date + 1.day))

      list = Lifelist::Advanced.over({}).sort(nil)

      assert_equal obs2.id, list.to_a.first.last_seen.id

    end

    test "it should return observations count" do

      obs = FactoryGirl.create(:observation)
      obs2 = FactoryGirl.create(:observation)

      list = Lifelist::Advanced.over({}).sort(nil)

      assert_equal 2, list.to_a.first.obs_count

    end

    test 'Properly associate card post with lifer' do
      post = FactoryGirl.create(:post)
      card = FactoryGirl.create(:card, post: post)
      obs = FactoryGirl.create(:observation, card: card)
      list = Lifelist::Advanced.full
      list.set_posts_scope(Post.public_posts)
      assert_equal post, list.first.first_seen.main_post
    end

    test 'Properly associate observation post with lifer' do
      post = FactoryGirl.create(:post)
      obs = FactoryGirl.create(:observation, post: post)
      list = Lifelist::Advanced.full
      list.set_posts_scope(Post.public_posts)
      assert_equal post, list.first.first_seen.main_post
    end

  end

end
