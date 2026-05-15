# frozen_string_literal: true

require "test_helper"

class PostCoreTest < ActiveSupport::TestCase
  test "slug is required" do
    core = build(:post_core, slug: "")
    assert_not_predicate core, :valid?
  end

  test "slug cannot contain space" do
    core = build(:post_core, slug: "kyiv observations")
    assert_not_predicate core, :valid?
  end
end
