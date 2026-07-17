# frozen_string_literal: true

require "test_helper"
require "functional/either"

class EitherTest < ActiveSupport::TestCase
  # Minimal Either implementation, mirroring how Flickr::Result / Flickr::Error wire the module up.
  module Sample
    include Functional::Either

    class Value
      include Functional::Either::Value
    end

    class Error
      include Functional::Either::Error
    end

    VALUE_CLASS = Value
    ERROR_CLASS = Error
  end

  test "value builds a value object wrapping the given value" do
    result = Sample.value(42)
    assert_instance_of Sample::Value, result
    assert_equal 42, result.get
  end

  test "error builds an error object" do
    result = Sample.error("boom")
    assert_instance_of Sample::Error, result
  end

  test "value is valid and not an error" do
    result = Sample.value(42)
    assert_predicate result, :valid?
    assert_not_predicate result, :error?
  end

  test "error is an error and not valid" do
    result = Sample.error("boom")
    assert_predicate result, :error?
    assert_not_predicate result, :valid?
  end

  test "error exposes the message through errors" do
    assert_includes Sample.error("boom").errors[:base], "boom"
  end

  test "get on an error raises" do
    error = Sample.error("boom")
    exception = assert_raises(Functional::Either::Error::EitherErrorException) { error.get }
    assert_equal "boom", exception.message
  end

  test "any method called on an error returns the error itself" do
    error = Sample.error("boom")
    assert_same error, error.whatever
    assert_same error, error.map { |x| x }
    assert_respond_to error, :anything_at_all
  end

  test "apply combines two values" do
    result = Sample.value([1, 2]).apply.concat(Sample.value([3]))
    assert_instance_of Sample::Value, result
    assert_equal [1, 2, 3], result.get
  end

  test "apply propagates the error when the argument is an error" do
    error = Sample.error("boom")
    result = Sample.value([1, 2]).apply.concat(error)
    assert_same error, result
  end

  test "apply on an error returns the error and never touches the argument" do
    error = Sample.error("boom")
    result = error.apply.concat(Sample.value([3]))
    assert_same error, result
  end

  test "value applicator responds to any method" do
    assert_respond_to Sample.value([1]).apply, :concat
    assert_respond_to Sample.error("boom").apply, :concat
  end
end
