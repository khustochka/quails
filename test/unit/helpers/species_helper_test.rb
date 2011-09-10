require 'test_helper'

class SpeciesHelperTest < ActionView::TestCase

  test "sp_humanize for regular name" do
    "Crex_crex".sp_humanize.should == "Crex crex"
  end

  test "sp_humanize for space and downcase" do
    "crex crex".sp_humanize.should == "Crex crex"
  end

end
