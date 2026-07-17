# frozen_string_literal: true

require "test_helper"

# Ukrainian and Russian month and day names change form depending on context:
# "1 січня" (with a day) vs "Січень" (standing alone).
class SlavicDatetimeTest < ActiveSupport::TestCase
  setup do
    @date = Date.new(1985, 1, 6) # a Sunday
  end

  test "month name with a day uses the common form" do
    assert_equal "6 січня", I18n.l(@date, format: "%-d %B", locale: :uk)
    assert_equal "6 января", I18n.l(@date, format: "%-d %B", locale: :ru)
  end

  test "month name without a day uses the standalone form" do
    assert_equal "Січень 1985", I18n.l(@date, format: "%B %Y", locale: :uk)
    assert_equal "Январь 1985", I18n.l(@date, format: "%B %Y", locale: :ru)
  end

  test "abbreviated month name with a day uses the common form" do
    assert_equal "6 січ.", I18n.l(@date, format: "%-d %b", locale: :uk)
  end

  test "abbreviated month name without a day uses the standalone form" do
    assert_equal "січ. 1985", I18n.l(@date, format: "%b %Y", locale: :uk)
  end

  test "day name at the start of the format uses the standalone form" do
    assert_equal "Неділя", I18n.l(@date, format: "%A", locale: :uk)
  end

  test "day name inside the format uses the common form" do
    assert_equal "6, неділя", I18n.l(@date, format: "%-d, %A", locale: :uk)
  end

  # NOTE: for abbreviated day names the two lists are capitalized the other way round than the full
  # ones, so a leading %a picks "Нд" while %A picks "Неділя".
  test "abbreviated day name at the start of the format uses the common form" do
    assert_equal "Нд", I18n.l(@date, format: "%a", locale: :uk)
  end

  test "abbreviated day name inside the format uses the standalone form" do
    assert_equal "6 нд", I18n.l(@date, format: "%-d %a", locale: :uk)
  end

  test "the long format renders the month in the common form" do
    assert_equal "6 січня 1985", I18n.l(@date, format: :long, locale: :uk)
  end
end
