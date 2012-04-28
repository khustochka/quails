require "test_helper"

class CoreExtTest < ActiveSupport::TestCase

  test "sp_humanize for regular name" do
    "Crex_crex".sp_humanize.should == "Crex crex"
  end

  test "sp_humanize for space and downcase" do
    "crex crex".sp_humanize.should == "Crex crex"
  end

  test 'get common values of the hash' do
    y = [{a: 1, b: 3}, {a: 2, b: 3}, {a: 1, b: 3}]
    y.inject(&:&).should == {b: 3}

    z = [{a: 1, b: 3}, {a: 1}, {a: 1, b: 3}]
    z.inject(&:&).should == {a: 1}
  end

end
