require "test_helper"

class CoreExtTest < ActiveSupport::TestCase

  test "sp_humanize for regular name" do
    assert_equal "Crex crex", "Crex_crex".sp_humanize
  end

  test "sp_humanize for space and downcase" do
    assert_equal "Crex crex", "crex crex".sp_humanize
  end

  test 'get common values of the hash' do
    y = [{a: 1, b: 3}, {a: 2, b: 3}, {a: 1, b: 3}]
    assert_equal({b: 3}, y.inject(&:&))

    z = [{a: 1, b: 3}, {a: 1}, {a: 1, b: 3}]
    assert_equal({a: 1}, z.inject(&:&))
  end

end
