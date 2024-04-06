# frozen_string_literal: true

require "test_helper"

module Lifelist
  class AdvancedTest < ActiveSupport::TestCase
    test "it should have species" do
      obs = FactoryBot.create(:observation)

      list = Lifelist::Advanced.over({}).sort(nil)

      assert_equal obs.species, list.to_a.first.species
    end

    test "it should have first seen observation" do
      obs = FactoryBot.create(:observation)
      obs2 = FactoryBot.create(:observation, card: FactoryBot.create(:card, observ_date: obs.card.observ_date + 1.day))

      list = Lifelist::Advanced.over({}).sort(nil)

      assert_equal obs.id, list.to_a.first.first_seen.id
    end

    test "it should return last seen observation" do
      obs = FactoryBot.create(:observation)
      obs2 = FactoryBot.create(:observation, card: FactoryBot.create(:card, observ_date: obs.card.observ_date + 1.day))

      list = Lifelist::Advanced.over({}).sort(nil)

      assert_equal obs2.id, list.to_a.first.last_seen.id
    end

    test "it should return observations count" do
      obs = FactoryBot.create(:observation)
      obs2 = FactoryBot.create(:observation)

      list = Lifelist::Advanced.over({}).sort(nil)

      assert_equal 2, list.to_a.first.obs_count
    end

    test "Properly associate card post with lifer" do
      post = FactoryBot.create(:post)
      card = FactoryBot.create(:card, post: post)
      obs = FactoryBot.create(:observation, card: card)
      list = Lifelist::Advanced.full
      list.posts_scope = Post.public_posts
      assert_equal post, list.first.first_seen.main_post
    end

    test "Properly associate observation post with lifer" do
      post = FactoryBot.create(:post)
      obs = FactoryBot.create(:observation, post: post)
      list = Lifelist::Advanced.full
      list.posts_scope = Post.public_posts
      assert_equal post, list.first.first_seen.main_post
    end

    test "lifelist with seen species only" do
      obs = FactoryBot.create(:observation, taxon: taxa(:pasdom))
      obs2 = FactoryBot.create(:observation, taxon: taxa(:jyntor), voice: true)

      list = Lifelist::Advanced.over({ exclude_heard_only: true }).sort(nil)

      assert_not_includes list.to_a.map(&:species).map(&:name_sci), taxa(:jyntor).species.name_sci
    end
  end
end
