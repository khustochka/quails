require "test_helper"

class CoreExtTest < ActiveSupport::TestCase

  test "sp_humanize for regular name" do
    "Crex_crex".sp_humanize.should == "Crex crex"
  end

  test "sp_humanize for space and downcase" do
    "crex crex".sp_humanize.should == "Crex crex"
  end

  test 'get single value over hash' do
    y = [{a: 1}, {a: 2}, {a: 1}]
    y.extend(CommonValueSelector)
    y.common_value(:a).should be_nil

    z = [{a: 1}, {a: 1}, {a: 1}]
    z.extend(CommonValueSelector)
    z.common_value(:a).should == 1
  end

end