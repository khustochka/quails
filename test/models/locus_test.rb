require 'test_helper'

class LocusTest < ActiveSupport::TestCase
  test "locus factory is valid" do
    create(:locus)
    create(:locus)
  end

  test 'do not save locus with empty slug' do
    loc = build(:locus, slug: '')
    assert_raise(ActiveRecord::RecordInvalid) { loc.save! }
  end

  test 'do not save locus with existing slug' do
    loc = build(:locus, slug: 'kiev')
    assert_raise(ActiveRecord::RecordInvalid) { loc.save! }
  end

  test 'properly find all locus subregions' do
    loc = seed(:ukraine)
    actual = loc.subregion_ids
    expected = Locus.where(slug: ['ukraine', 'kiev_obl', 'kherson_obl', 'kherson', 'chernihiv']).pluck(:id)
    not_expected = Locus.where(slug: ['usa', 'new_york', 'brooklyn', 'hoboken']).pluck(:id)
    assert_equal [], expected - actual, 'Some expected values are not included'
    assert_equal [], not_expected & actual, 'Some unexpected values are included'
  end

  test "subregions of the Arabat Spit" do
    loc = seed(:arabat_spit)
    actual = loc.subregion_ids
    expected = Locus.where("slug LIKE 'arabat%'").pluck(:id)
    assert_equal expected, actual
  end

  test 'do not destroy locus if it has child locations' do
    loc = seed(:ukraine)
    assert_raise(Ancestry::AncestryException) { loc.destroy }
    assert loc
  end

  test 'do not destroy locus if it has associated cards (and no child loci)' do
    loc = seed(:les_i_pole)
    observation = create(:observation, card: create(:card, locus: loc))
    assert loc.descendants.empty?
    assert_raise(ActiveRecord::DeleteRestrictionError) { loc.destroy }
    assert observation.reload
    assert_equal loc, observation.card.locus
  end

  test 'do not destroy locus if it has associated observations (patch) and no cards' do
    loc = seed(:les_i_pole)
    observation = create(:observation, card: create(:card, locus: seed(:brovary)), patch: loc)
    assert loc.cards.empty?
    assert_raise(ActiveRecord::DeleteRestrictionError) { loc.destroy }
  end

  test "proper public parent for a private locus" do
    brvr = seed(:brovary)
    loc = create(:locus, parent_id: brvr.id, private_loc: true)
    loc2 = create(:locus, parent_id: loc.id, private_loc: true)
    assert_equal brvr, loc2.public_locus
  end

  test "proper public locus for self" do
    brvr = seed(:brovary)
    assert_equal brvr, brvr.public_locus
  end

  test "#country" do
    brvr = seed(:brovary)
    assert_equal 'ukraine', brvr.country.slug
  end

  test "#country for country should be self" do
    ukr = seed(:ukraine)
    assert_equal 'ukraine', ukr.country.slug
  end

  test "default locus full name if name format is not set" do
    brvr = seed(:brovary)
    brvr.update_attributes(name_format: "")
    I18n.with_locale(:en) do
      assert_equal "Brovary, Ukraine", brvr.decorated.full_name
    end
  end

  test "use name format to show full name" do
    brvr = seed(:brovary)
    brvr.update_attributes(name_format: "%self, %oblast, %country")
    I18n.with_locale(:en) do
      assert_equal "Brovary, Kiev oblast, Ukraine", brvr.decorated.full_name
    end
  end

end
