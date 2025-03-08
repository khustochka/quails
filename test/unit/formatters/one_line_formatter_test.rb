# frozen_string_literal: true

require "test_helper"

class OneLineFormatterTest < ActionDispatch::IntegrationTest

  test "no span_caps by default" do
    assert_equal "xxx ABC xxx", OneLineFormatter.apply("xxx ABC xxx")
  end

  test "Cyrillic double quotes" do
    assert_equal "Новий «лайфер»", OneLineFormatter.apply('Новий "лайфер"')
  end
end
