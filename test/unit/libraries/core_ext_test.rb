# frozen_string_literal: true

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase

  test 'get common values of the hash' do
    y = [{a: 1, b: 3}, {a: 2, b: 3}, {a: 1, b: 3}]
    assert_equal({b: 3}, y.inject(:&))

    z = [{a: 1, b: 3}, {a: 1}, {a: 1, b: 3}]
    assert_equal({a: 1}, z.inject(:&))
  end

  test "nil is not meaningful" do
    assert_not_predicate nil, :meaningful?
  end

  test "empty string is not meaningful" do
    assert_not_predicate "", :meaningful?
  end

  test "false is meaningful" do
    assert_predicate false, :meaningful?
  end

end
