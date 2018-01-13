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
    loc = loci(:ukraine)
    actual = loc.subregion_ids
    expected = Locus.where(slug: ['ukraine', 'kiev_obl', 'kiev', 'brovary']).pluck(:id)
    not_expected = Locus.where(slug: ['usa', 'new_york', 'nyc']).pluck(:id)
    assert_equal [], expected - actual, 'Some expected values are not included'
    assert_equal [], not_expected & actual, 'Some unexpected values are included'
  end

  test "subregions of the Arabat Spit" do
    loc = create(:locus, slug: :arabat_spit, parent: loci("ukraine"))
    loc1 = create(:locus, slug: :arabat_spit_kherson, parent: loci("ukraine"))
    loc2 = create(:locus, slug: :arabat_spit_krym, parent: loci("ukraine"))
    loc3 = create(:locus, slug: :hen_horka, parent: loc1)
    actual = loc.subregion_ids
    assert_equal [loc.id, loc1.id, loc2.id, loc3.id].to_set, actual.to_set
  end

  test 'do not destroy locus if it has child locations' do
    loc = loci(:ukraine)
    assert_raise(Ancestry::AncestryException) { loc.destroy }
    assert loc
  end

  test 'do not destroy locus if it has associated cards (and no child loci)' do
    loc = loci(:brovary)
    observation = create(:observation, card: create(:card, locus: loc))
    assert_predicate loc.descendants, :empty?
    assert_raise(ActiveRecord::DeleteRestrictionError) { loc.destroy }
    assert observation.reload
    assert_equal loc, observation.card.locus
  end

  test 'do not destroy locus if it has associated observations (patch) and no cards' do
    loc = loci(:brovary)
    observation = create(:observation, card: create(:card, locus: loci(:kiev_obl)), patch: loc)
    assert_predicate loc.cards, :empty?
    assert_raise(ActiveRecord::DeleteRestrictionError) { loc.destroy }
  end

  test "proper public parent for a private locus" do
    brvr = loci(:brovary)
    loc = create(:locus, parent_id: brvr.id, private_loc: true)
    loc2 = create(:locus, parent_id: loc.id, private_loc: true)
    assert_equal brvr, loc2.public_locus
  end

  test "proper public locus for self" do
    brvr = loci(:brovary)
    assert_equal brvr, brvr.public_locus
  end

  test "#country" do
    brvr = loci(:brovary)
    assert_equal 'ukraine', brvr.country.slug
  end

  test "#country for country should be self" do
    ukr = loci(:ukraine)
    assert_equal 'ukraine', ukr.country.slug
  end

  test "default locus full name if name format is not set" do
    brvr = loci(:brovary)
    brvr.update_attributes(name_format: "")
    I18n.with_locale(:en) do
      assert_equal "Brovary, Ukraine", brvr.decorated.full_name
    end
  end

  test "use name format to show full name" do
    brvr = loci(:brovary)
    brvr.update_attributes(name_format: "%self, %oblast, %country")
    I18n.with_locale(:en) do
      assert_equal "Brovary, Kiev oblast, Ukraine", brvr.decorated.full_name
    end
  end

  test "%parent pattern in name_format" do
    brvr = loci(:brovary)
    brvr.update_attributes(name_format: "%self, %parent, %country")
    I18n.with_locale(:en) do
      assert_equal "Brovary, Kiev oblast, Ukraine", brvr.decorated.full_name
    end
  end

  test "short name should strip everything after city" do
    kiev = loci(:kiev)
    troeshina = FactoryBot.create(:locus, slug: "troya", name_en: "Troya", parent: kiev, name_format: "%self, %city, %oblast, %country")
    I18n.with_locale(:en) do
      assert_equal "Troya, Kiev City", troeshina.decorated.short_full_name
    end
  end

  test "short name should strip country if city not defined" do
    brvr = loci(:brovary)
    I18n.with_locale(:en) do
      assert_equal "Brovary, Kiev oblast", brvr.decorated.short_full_name
    end
  end

  test "short preserve self" do
    ua = loci(:ukraine)
    I18n.with_locale(:en) do
      assert_equal "Ukraine", ua.decorated.short_full_name
    end
  end

end
