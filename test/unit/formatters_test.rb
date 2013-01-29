# -- encoding: utf-8 --

require 'test_helper'

class FormattersTest < ActionView::TestCase

  test "no span_caps by default" do
    assert_equal  "xxx ABC xxx", OneLineFormatter.apply("xxx ABC xxx")
  end

  test "Russian double quotes" do
    assert_equal  'Новый &#171;лайфер&#187;', OneLineFormatter.apply('Новый "лайфер"')
  end

end
