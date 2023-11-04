# frozen_string_literal: true

require "test_helper"
require "ebird/checklist"

class EBirdChecklistTest < ActiveSupport::TestCase
  def parse_duration(str)
    str.match(EBird::Checklist::DURATION_REGEX)
  end

  test "properly parse minutes only duration" do
    md = parse_duration("Duration: 58 minute(s)")
    assert_equal 0, md[1].to_i
    assert_equal 58, md[2].to_i
  end

  test "properly parse hours only duration" do
    md = parse_duration("Duration: 1 hour(s)")
    assert_equal 1, md[1].to_i
    assert_equal 0, md[2].to_i
  end

  test "properly parse hours and minutes duration" do
    md = parse_duration("Duration: 1 hour(s), 8 minute(s)")
    assert_equal 1, md[1].to_i
    assert_equal 8, md[2].to_i
  end
end
