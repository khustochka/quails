# frozen_string_literal: true

require "test_helper"

class CardsHelperTest < ActionView::TestCase
  test "suggested dates always offer today and yesterday" do
    result = suggested_dates(Card.new)

    assert_equal ["Today"], result[Time.zone.today]
    assert_equal ["Yesterday"], result[Time.zone.yesterday]
  end

  test "suggested dates offer the day after the last reported card" do
    create(:card, observ_date: "2010-06-18")
    create(:card, observ_date: "2011-06-18")

    result = suggested_dates(Card.new)

    assert_equal ["Last unreported"], result[Date.new(2011, 6, 19)]
  end

  test "suggested dates for a new card do not mention that card" do
    create(:card, observ_date: "2011-06-18")

    result = suggested_dates(Card.new)

    assert_not_includes result.values.flatten, "Same day as this card"
    assert_not_includes result.values.flatten, "Next day to this card"
  end

  test "suggested dates for an existing card offer its own day and the next" do
    card = create(:card, observ_date: "2010-06-18")

    result = suggested_dates(card)

    assert_equal ["Same day as this card"], result[Date.new(2010, 6, 18)]
    assert_equal ["Next day to this card"], result[Date.new(2010, 6, 19)]
  end

  test "fast loci are indexed by slug" do
    winnipeg = create(:locus, slug: "winnipeg", loc_type: "city")
    create(:locus, slug: "some_other_place")

    result = fast_loci

    assert_equal winnipeg, result["winnipeg"]
    assert_not_includes result.keys, "some_other_place"
  end

  test "post_attach_detach_link offers to attach a card of another post" do
    core = create(:post_core)
    card = create(:card)

    result = post_attach_detach_link(card, core.id)

    assert_includes result, "Attach to this post"
    assert_includes result, "card[post_core_id]=#{core.id}"
  end

  test "post_attach_detach_link offers to detach a card of this post" do
    core = create(:post_core)
    card = create(:card, post_core: core)

    result = post_attach_detach_link(card, core.id)

    assert_includes result, "Detach from this post"
    assert_includes result, "card[post_core_id]="
    assert_not_includes result, "card[post_core_id]=#{core.id}"
  end
end
