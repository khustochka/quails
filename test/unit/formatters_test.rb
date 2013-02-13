# -- encoding: utf-8 --

require 'test_helper'

class FormattersTest < ActionView::TestCase

  test "no span_caps by default" do
    assert_equal  "xxx ABC xxx", OneLineFormatter.apply("xxx ABC xxx")
  end

  test "Russian double quotes" do
    assert_equal  'Новый &#171;лайфер&#187;', OneLineFormatter.apply('Новый "лайфер"')
  end

  test "Post with species link" do
    post = create(:post, text: "This is a [Blue Tut|parcae]")
    assert_equal "<p>This is a <a href=\"/species/Parus_caeruleus\" class=\"sp_link\">Blue Tut</a></p>", post.formatted.text
  end

  test "Post with unknown species" do
    post = create(:post, text: "This is a [Frodo hobbitana]")
    assert_equal "<p>This is a <i class=\"sci_name\">Frodo hobbitana</i></p>", post.formatted.text
  end

  test "Post with link to another post" do
    post1 = create(:post, slug: "post_for_link")
    post = create(:post, text: "This is a [#post|post_for_link]")
    assert_equal "<p>This is a <a href=\"/#{post1.year}/#{post1.month}/post_for_link\">post</a></p>", post.formatted.text
  end

end
