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

  test "country_slug_by_id maps loci to their country via ancestry" do
    ids = [loci(:ukraine), loci(:brovary), loci(:kyiv), loci(:usa), loci(:nyc)].map(&:id)
    result = Locus.country_slug_by_id(Locus.where(id: ids))

    assert_equal "ukraine", result[loci(:ukraine).id], "country maps to itself"
    assert_equal "ukraine", result[loci(:brovary).id]
    assert_equal "ukraine", result[loci(:kyiv).id]
    assert_equal "usa", result[loci(:usa).id]
    assert_equal "usa", result[loci(:nyc).id]
  end

  test "country_slug_by_id leaves loci without a country unmapped" do
    continent = create(:locus, slug: :europe, loc_type: "continent")
    result = Locus.country_slug_by_id(Locus.where(id: continent.id))
    assert_nil result[continent.id]
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

  # cached_public_locus_id maintenance

  test "cached_public_locus set to self on create for public locus" do
    loc = create(:locus, private_loc: false)
    assert_equal loc, loc.cached_public_locus
  end

  test "cached_public_locus set to nearest public ancestor on create for private locus" do
    brvr = loci(:brovary)
    loc = create(:locus, parent_id: brvr.id, private_loc: true)
    assert_equal brvr, loc.cached_public_locus
  end

  test "cached_public_locus updated when locus becomes private" do
    brvr = loci(:brovary)
    loc = create(:locus, parent_id: brvr.id, private_loc: false)
    assert_equal loc, loc.cached_public_locus

    loc.update!(private_loc: true)
    assert_equal brvr, loc.reload.cached_public_locus
  end

  test "cached_public_locus updated when locus becomes public" do
    brvr = loci(:brovary)
    loc = create(:locus, parent_id: brvr.id, private_loc: true)
    assert_equal brvr, loc.cached_public_locus

    loc.update!(private_loc: false)
    assert_equal loc, loc.reload.cached_public_locus
  end

  test "descendants cached_public_locus updated when ancestor becomes private" do
    brvr = loci(:brovary)
    parent = create(:locus, parent_id: brvr.id, private_loc: false)
    child = create(:locus, parent_id: parent.id, private_loc: true)
    assert_equal parent, child.reload.cached_public_locus

    parent.update!(private_loc: true)
    assert_equal brvr, child.reload.cached_public_locus
  end

  test "descendants cached_public_locus updated when ancestry changes" do
    brvr = loci(:brovary)
    kyiv = loci(:kyiv)
    parent = create(:locus, parent_id: brvr.id, private_loc: false)
    child = create(:locus, parent_id: parent.id, private_loc: true)
    assert_equal parent, child.reload.cached_public_locus

    parent.update!(parent: kyiv)
    assert_equal parent, child.reload.cached_public_locus
  end

  test "promote_children! re-parents children to the locus's parent" do
    grandparent = create(:locus)
    locus = create(:locus, parent: grandparent)
    child_a = create(:locus, parent: locus)
    child_b = create(:locus, parent: locus)

    assert_equal 2, locus.promote_children!

    assert_equal grandparent, child_a.reload.parent
    assert_equal grandparent, child_b.reload.parent
    assert_empty locus.reload.children
    assert_equal [child_a, child_b].map(&:id).sort,
      grandparent.children.where(id: [child_a, child_b]).pluck(:id).sort
  end

  test "promote_children! makes children roots when locus is a root" do
    locus = create(:locus)
    child = create(:locus, parent: locus)

    assert_equal 1, locus.promote_children!

    assert_nil child.reload.parent
    assert_predicate child, :is_root?
  end

  test "promote_children! returns zero and changes nothing when there are no children" do
    locus = create(:locus, parent: create(:locus))

    assert_equal 0, locus.promote_children!
  end

  test "promote_children! updates descendants cached_public_locus" do
    grandparent = create(:locus, private_loc: false)
    locus = create(:locus, parent: grandparent, private_loc: true)
    child = create(:locus, parent: locus, private_loc: false)
    assert_equal child, child.reload.cached_public_locus

    locus.promote_children!

    # Child is now public directly under grandparent; nearest public is itself.
    assert_equal child, child.reload.cached_public_locus
    assert_equal grandparent, child.reload.parent
  end

  test "promote_children! clears cached_parent pointing at the old parent" do
    grandparent = create(:locus)
    locus = create(:locus, parent: grandparent)
    child = create(:locus, parent: locus, cached_parent: locus)

    locus.promote_children!

    # New parent (grandparent) becomes the cached_parent; the stale old-parent ref is gone.
    assert_equal grandparent, child.reload.cached_parent
  end

  test "promote_children! sets the new parent as cached_parent when not in the chain" do
    grandparent = create(:locus)
    locus = create(:locus, parent: grandparent)
    child = create(:locus, parent: locus)

    locus.promote_children!

    assert_equal grandparent, child.reload.cached_parent
  end

  test "promote_children! sets the new parent as cached_city when it is a city" do
    grandparent = create(:locus, loc_type: "city")
    locus = create(:locus, parent: grandparent)
    child = create(:locus, parent: locus)

    locus.promote_children!

    assert_equal grandparent, child.reload.cached_city
    assert_nil child.cached_parent
  end

  test "promote_children! does not duplicate the new parent already in the cached chain" do
    grandparent = create(:locus)
    locus = create(:locus, parent: grandparent)
    child = create(:locus, parent: locus, cached_subdivision: grandparent)

    locus.promote_children!

    child.reload
    assert_equal grandparent, child.cached_subdivision
    assert_nil child.cached_parent
    assert_nil child.cached_city
  end

  test "promote_children! clears old-parent cached_parent even when locus is a root" do
    locus = create(:locus)
    child = create(:locus, parent: locus, cached_parent: locus)

    locus.promote_children!

    assert_nil child.reload.cached_parent
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

  test "blank loc_type is normalized to nil" do
    loc = create(:locus, loc_type: "")
    assert_nil loc.loc_type
  end

  test "new_type is required" do
    loc = build(:locus)
    loc.new_type = nil
    assert_not loc.valid?
    assert_predicate loc.errors[:new_type], :any?
  end

  test "new_type defaults to site for new records" do
    assert_equal "site", Locus.new.new_type
  end
end
