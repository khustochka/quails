require 'test_helper'

module NewLifelist

  class AdvancedTest < ActiveSupport::TestCase

    test "it should have species" do

      obs = FactoryGirl.create(:observation)

      list = NewLifelist::Advanced.over({}).sort(nil)

      assert_equal obs.species, list.to_a.first.species

    end

    test "it should have first seen observation" do

      obs = FactoryGirl.create(:observation)
      obs2 = FactoryGirl.create(:observation, card: FactoryGirl.create(:card, observ_date: obs.card.observ_date + 1.day))

      list = NewLifelist::Advanced.over({}).sort(nil)

      assert_equal obs.id, list.to_a.first.first_seen.id

    end

    test "it should return last seen observation" do

      obs = FactoryGirl.create(:observation)
      obs2 = FactoryGirl.create(:observation, card: FactoryGirl.create(:card, observ_date: obs.card.observ_date + 1.day))

      list = NewLifelist::Advanced.over({}).sort(nil)

      assert_equal obs2.id, list.to_a.first.last_seen.id

    end

    test "it should return observations count" do

      obs = FactoryGirl.create(:observation)
      obs2 = FactoryGirl.create(:observation)

      list = NewLifelist::Advanced.over({}).sort(nil)

      assert_equal 2, list.to_a.first.obs_count

    end

  end

end
