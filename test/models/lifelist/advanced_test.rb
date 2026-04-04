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

    test "first_seen locus is preloaded without extra queries" do
      FactoryBot.create(:observation)

      list = Lifelist::Advanced.over({}).sort(nil)
      recs = list.to_a

      assert_queries_count(0) do
        recs.each { |r| r.first_seen.locus }
      end
    end

    test "last_seen locus is preloaded without extra queries" do
      card1 = FactoryBot.create(:card, observ_date: Date.new(2020, 1, 1))
      card2 = FactoryBot.create(:card, observ_date: Date.new(2020, 2, 1))
      FactoryBot.create(:observation, card: card1)
      FactoryBot.create(:observation, card: card2)

      list = Lifelist::Advanced.over({}).sort(nil)
      recs = list.to_a

      assert_queries_count(0) do
        recs.each { |r| r.last_seen.locus }
      end
    end

    test "public_locus is preloaded without extra queries" do
      FactoryBot.create(:observation)

      list = Lifelist::Advanced.over({}).sort(nil)
      recs = list.to_a

      assert_queries_count(0) do
        recs.each { |r| r.first_seen.locus.public_locus }
      end
    end

    test "lifelist with seen species only" do
      obs = FactoryBot.create(:observation, taxon: taxa(:pasdom))
      obs2 = FactoryBot.create(:observation, taxon: taxa(:jyntor), voice: true)

      list = Lifelist::Advanced.over({ exclude_heard_only: true }).sort(nil)

      assert_not_includes list.to_a.map(&:species).map(&:name_sci), taxa(:jyntor).species.name_sci
    end
  end
end
