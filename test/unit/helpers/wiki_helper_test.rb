# -- encoding: utf-8 --

require 'test_helper'

class WikiHelperTest < ActionView::TestCase

  test "no span_caps by default" do
    assert_equal  "xxx ABC xxx", wikify_one_line("xxx ABC xxx")
  end

  test "Russian double quotes" do
    assert_equal  'Новый &#171;лайфер&#187;', wikify_one_line('Новый "лайфер"')
  end

end
