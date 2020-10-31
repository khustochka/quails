# frozen_string_literal: true

require "test_helper"

class CollationTest < ActiveSupport::TestCase
  test "proper sorting (collation)" do
    sps = Species.order(:name_sci).where("name_sci LIKE 'Passer%'")
    correct = sps.index { |s| s.name_sci == "Passer domesticus" } < sps.index { |s| s.name_sci == "Passerculus sandwichensis" }
    assert correct, 'Incorrect species sorting order (collation should be "C")'
  end
end
