# frozen_string_literal: true

require "test_helper"

class SpeciesParameterizeTest < ActiveSupport::TestCase
  test "sp_humanize for regular name" do
    assert_equal "Crex crex", Species.humanize("Crex_crex")
  end

  test "sp_humanize for space and downcase" do
    assert_equal "Crex crex", Species.humanize("crex crex")
  end
end
