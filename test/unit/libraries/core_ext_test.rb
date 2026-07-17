# frozen_string_literal: true

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  test "get common values of the hash" do
    y = [{ a: 1, b: 3 }, { a: 2, b: 3 }, { a: 1, b: 3 }]
    assert_equal({ b: 3 }, y.inject(:&))

    z = [{ a: 1, b: 3 }, { a: 1 }, { a: 1, b: 3 }]
    assert_equal({ a: 1 }, z.inject(:&))
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

  test "if_present yields the receiver when present" do
    assert_equal 10, 5.if_present { |n| n * 2 }
    assert_equal "AB", "ab".if_present(&:upcase)
  end

  test "if_present returns nil without yielding when blank" do
    assert_nil nil.if_present { raise "should not be called" }
    assert_nil "".if_present { raise "should not be called" }
    assert_nil [].if_present { raise "should not be called" }
  end

  test "fast_index_by indexes elements by the block result" do
    assert_equal({ 1 => "a", 2 => "bb" }, %w(a bb).fast_index_by(&:size))
  end

  test "fast_index_by keeps the first element for a duplicate key" do
    assert_equal({ 1 => "a", 2 => "bb" }, %w(a bb c).fast_index_by(&:size))
  end

  test "fast_index_by without a block returns an enumerator" do
    assert_kind_of Enumerator, %w(a bb).fast_index_by
    assert_equal 2, %w(a bb).fast_index_by.size
  end
end
