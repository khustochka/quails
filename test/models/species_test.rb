# frozen_string_literal: true

require "test_helper"

class SpeciesTest < ActiveSupport::TestCase
  test "do not save species with empty Latin name" do
    sp = Species.find_by!(code: :hirrus)
    sp.name_sci = ""
    assert_not sp.save, "Record saved while expected to fail."
  end

  test "empty code should be turned into nil" do
    sp = Species.find_by!(code: :hirrus)
    sp.code = ""
    sp.save!
    assert_nil sp.code
  end

  test "not be saved with existing Latin name" do
    sp = Species.find_by!(code: :hirrus)
    sp.name_sci = species(:saxola).name_sci
    assert_not sp.save, "Record saved while expected to fail."
  end

  test "do not save species with existing code" do
    sp = Species.find_by!(code: :hirrus)
    sp.code = "saxola"
    assert_not sp.save, "Record saved while expected to fail."
  end

  test "legacy code should not be equal to another species code" do
    sp = Species.find_by!(code: :hirrus)
    sp.legacy_code = "saxola"
    assert_not sp.save, "Record saved while expected to fail."
  end

  test "code should not be equal to another species legacy code" do
    sp = Species.find_by!(code: :hirrus)
    sp.code = "saxtor"
    assert_not sp.save, "Record saved while expected to fail."
  end

  test "One species can have the same code and legacy code" do
    sp = Species.find_by!(code: :saxola)
    sp.legacy_code = "saxtor"
    sp.code = "saxtor"
    assert_predicate sp, :valid?
    sp.save!
  end

  test "Species post_cores" do
    blogpost1 = create(:post)
    blogpost2 = create(:post)
    card = create(:card, post_core: blogpost1.post_core)
    obs1 = create(:observation, card: card)
    # Add more to test uniqueness
    create(:observation, card: card)
    create(:observation, card: card)
    create(:observation, card: card)
    create(:observation, post_core: blogpost2.post_core)

    cores = obs1.species.post_cores.to_a

    assert_equal 2, cores.size
    assert_includes cores, blogpost1.post_core
    assert_includes cores, blogpost2.post_core
  end
end
