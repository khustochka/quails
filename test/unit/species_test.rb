require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase

  test 'do not save species with empty Latin name' do
    sp = seed(:parcae)
    sp.name_sci = ''
    assert_raise(ActiveRecord::RecordInvalid) { sp.save! }
  end

  test 'do not save species with empty code' do
    sp = seed(:parcae)
    sp.code = ''
    assert_raise(ActiveRecord::RecordInvalid) { sp.save! }
  end

  test 'not be saved with existing Latin name' do
    sp = seed(:parcae)
    sp.name_sci = 'Parus major'
    assert_raise(ActiveRecord::RecordInvalid) { sp.save! }
  end

  test 'do not save species with existing code' do
    sp = seed(:parcae)
    sp.code = 'parmaj'
    assert_raise(ActiveRecord::RecordInvalid) { sp.save! }
  end

  test 'do not destroy species if it has associated observations' do
    sp = seed(:parcae)
    observation = create(:observation, species: sp)
    assert_raise(ActiveRecord::DeleteRestrictionError) { sp.destroy }
    assert observation.reload
    assert_equal sp, observation.species
  end

  test 'sort by abundance' do
    create(:observation, species: seed(:pasdom))
    create(:observation, species: seed(:pasmon))
    create(:observation, species: seed(:pasmon))
    list = Species.by_abundance.to_a
    assert_equal seed(:pasmon).id, list[0].id
    assert_equal seed(:pasdom).id, list[1].id
    assert_equal Species.count, list.size
  end

  test "Species posts" do
    blogpost1 = create(:post)
    blogpost2 = create(:post)
    card = create(:card, post: blogpost1)
    obs1 = create(:observation, card: card)
    # Add more to test uniqueness
    create(:observation, card: card)
    create(:observation, card: card)
    create(:observation, card: card)
    obs2 = create(:observation, post: blogpost2)

    posts = obs1.species.posts.to_a

    assert_equal 2, posts.size
    assert posts.include?(blogpost1)
    assert posts.include?(blogpost2)
  end

end
