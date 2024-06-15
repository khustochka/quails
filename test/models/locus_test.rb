# frozen_string_literal: true

require "test_helper"

class LocusTest < ActiveSupport::TestCase
  test "locus factory is valid" do
    assert_predicate create(:locus), :valid?
    assert_predicate create(:locus), :valid?
  end

  test "autogenerate slug if empty" do
    loc = build(:locus, slug: "")
    assert loc.save
    assert_not_empty loc.slug
  end

  test "do not save locus with existing slug" do
    loc = build(:locus, slug: "kyiv")
    assert_not loc.valid?
  end

  test "cached country not set when there are no country in the ancestry" do
    loc = create(:locus, slug: "peru", loc_type: "country")
    assert_nil loc.cached_country
  end

  test "cached country is required if there is a country in the ancestry" do
    peru = create(:locus, slug: "peru", loc_type: "country")
    loc = create(:locus, slug: "lima", parent: peru)
    assert_equal loc.cached_country, peru
  end

  test "properly find all locus subregions" do
    loc = loci(:ukraine)
    actual = loc.subregion_ids
    expected = Locus.where(slug: ["ukraine", "kiev_obl", "kyiv", "brovary"]).ids
    not_expected = Locus.where(slug: ["usa", "new_york", "nyc"]).ids
    assert_empty expected - actual, "Some expected values are not included"
    assert_empty not_expected & actual, "Some unexpected values are included"
  end

  test "subregions of the Arabat Spit" do
    loc = create(:locus, slug: :arabat_spit, parent: loci("ukraine"))
    loc1 = create(:locus, slug: :arabat_spit_kherson, parent: loci("ukraine"))
    loc2 = create(:locus, slug: :arabat_spit_krym, parent: loci("ukraine"))
    loc3 = create(:locus, slug: :hen_horka, parent: loc1)
    actual = loc.subregion_ids
    assert_equal [loc.id, loc1.id, loc2.id, loc3.id].to_set, actual.to_set
  end

  test "5-MR regions" do
    loc = create(:locus, slug: "5mr")
    loc1 = create(:locus, slug: :area1, parent: loci("usa"), five_mile_radius: true)
    loc2 = create(:locus, slug: :area2, parent: loci("usa"))
    actual = loc.subregion_ids
    assert_equal [loc1.id].to_set, actual.to_set
  end

  test "do not destroy locus if it has child locations" do
    loc = loci(:ukraine)
    assert_raise(Ancestry::AncestryException) { loc.destroy }
    assert loc
  end

  test "do not destroy locus if it has associated cards (and no child loci)" do
    loc = loci(:brovary)
    observation = create(:observation, card: create(:card, locus: loc))
    assert_predicate loc.descendants, :empty?
    assert_raise(ActiveRecord::DeleteRestrictionError) { loc.destroy }
    assert observation.reload
    assert_equal loc, observation.card.locus
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
    assert_equal "ukraine", brvr.country.slug
  end

  test "#country for country should be self" do
    ukr = loci(:ukraine)
    assert_equal ukr, ukr.country
  end

  test "locus full name using cached data" do
    brvr = loci(:brovary)
    I18n.with_locale(:en) do
      assert_equal "Brovary, Kyiv oblast, Ukraine", brvr.decorated.full_name
    end
  end

  test "locus full name for patch should prepend it with parent name" do
    ohm = create(:locus,
      slug: "ohm", name_en: "Oak Hammock Marsh")
    centre = FactoryBot.create(:locus,
      slug: "centre", name_en: "Interpretive Centre", patch: true,
      parent: ohm, cached_parent: ohm)
    I18n.with_locale(:en) do
      assert_equal "Oak Hammock Marsh - Interpretive Centre", centre.decorated.full_name
    end
  end

  test "short name should strip everything after city" do
    kyiv = loci(:kyiv)
    troeshina = FactoryBot.create(:locus, slug: "troya", name_en: "Troya", parent: kyiv, cached_city: kyiv, cached_country: loci(:ukraine))
    I18n.with_locale(:en) do
      assert_equal "Troya, Kyiv City", troeshina.decorated.short_full_name
    end
  end

  test "short name should strip country if city not defined" do
    brvr = loci(:brovary)
    I18n.with_locale(:en) do
      assert_equal "Brovary, Kyiv oblast", brvr.decorated.short_full_name
    end
  end

  test "short preserve self" do
    ua = loci(:ukraine)
    I18n.with_locale(:en) do
      assert_equal "Ukraine", ua.decorated.short_full_name
    end
  end
end
