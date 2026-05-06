# frozen_string_literal: true

require "test_helper"

class LociCorrectableTest < ActionController::TestCase
  tests LociController

  setup do
    @correction = create(:correction, model_classname: "Locus", query: "loci.name_en ILIKE '%fix%'", sort_column: "slug")
    @locus1 = create(:locus, slug: "loc_a", name_en: "Fix me A")
    @locus2 = create(:locus, slug: "loc_b", name_en: "Fix me B")
    @locus3 = create(:locus, slug: "loc_c", name_en: "Fix me C")
    login_as_admin
  end

  test "when submitted with Skip it redirects to the next record" do
    put :update, params: { id: @locus1.to_param, correction: @correction.id, commit: CorrectableConcern::SKIP_VALUE, locus: { name_en: "New name" } }
    @locus1.reload
    assert_not_equal "New name", @locus1.name_en
    assert_redirected_to [:edit, @locus2, { correction: @correction.id }]
  end

  test "when submitted with Save it saves and returns to the same edit form" do
    put :update, params: { id: @locus1.to_param, correction: @correction.id, commit: CorrectableConcern::SAVE_VALUE, locus: { name_en: "New name" } }
    @locus1.reload
    assert_equal "New name", @locus1.name_en
    assert_redirected_to [:edit, @locus1, { correction: @correction.id }]
  end

  test "when submitted with Save and next it saves and redirects to the next record" do
    put :update, params: { id: @locus1.to_param, correction: @correction.id, commit: CorrectableConcern::SAVE_AND_NEXT_VALUE, locus: { name_en: "New name" } }
    @locus1.reload
    assert_equal "New name", @locus1.name_en
    assert_redirected_to [:edit, @locus2, { correction: @correction.id }]
  end

  test "when submitted with errors (Save) it returns to the same edit form" do
    put :update, params: { id: @locus1.to_param, correction: @correction.id, commit: CorrectableConcern::SAVE_VALUE, locus: { slug: "BAD SLUG!" } }
    original_slug = @locus1.slug
    @locus1.reload
    assert_equal original_slug, @locus1.slug
    assert_template :form
  end

  test "when the last record is reached it redirects to the correction page with a flash message" do
    put :update, params: { id: @locus3.to_param, correction: @correction.id, commit: CorrectableConcern::SAVE_AND_NEXT_VALUE, locus: { name_en: "New name" } }
    @locus3.reload
    assert_equal "New name", @locus3.name_en
    assert_redirected_to [:edit, @correction]
    assert_equal "You have reached the last record!", flash[:notice]
  end
end
