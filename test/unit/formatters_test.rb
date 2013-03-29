# -- encoding: utf-8 --

require 'test_helper'

class FormattersTest < ActionView::TestCase

  test "no span_caps by default" do
    assert_equal "xxx ABC xxx", OneLineFormatter.apply("xxx ABC xxx")
  end

  test "Russian double quotes" do
    assert_equal 'Новый &#171;лайфер&#187;', OneLineFormatter.apply('Новый "лайфер"')
  end

  test "Post with species link" do
    post = create(:post, text: "This is a [Blue Tut|parcae]")
    assert_equal "<p>This is a <a href=\"/species/Parus_caeruleus\" class=\"sp_link\">Blue Tut</a></p>",
                 post.formatted.for_site.text
  end

  test "Post with unknown species" do
    post = create(:post, text: "This is a [Frodo hobbitana]")
    assert_equal "<p>This is a <i class=\"sci_name\">Frodo hobbitana</i></p>",
                 post.formatted.for_site.text
  end

  test "Post with link to another post" do
    post1 = create(:post, slug: "post_for_link")
    post = create(:post, text: "This is a [#post|post_for_link]")
    assert_equal "<p>This is a <a href=\"/#{post1.year}/#{post1.month}/post_for_link\">post</a></p>",
                 post.formatted.for_site.text
  end

  test "LJ Post with species link" do
    post = create(:post, text: "This is a [Blue Tut|parcae]")
    assert_equal "<p>This is a <b title=\"Parus caeruleus\">Blue Tut</b></p>",
                 post.formatted.for_lj.text
  end

  test "LJ Post with unknown species" do
    post = create(:post, text: "This is a [Frodo hobbitana]")
    assert_equal "<p>This is a <i class=\"sci_name\">Frodo hobbitana</i></p>",
                 post.formatted.for_lj.text
  end

  test "LJ Post with link to another post in LJ" do
    Settings.create(key: 'lj_user', value: {name: 'stonechat'})
    post1 = create(:post, slug: "post_for_link", lj_url_id: "1111")
    post = create(:post, text: "This is a [#post|post_for_link]")
    assert_equal "<p>This is a <a href=\"http://stonechat.livejournal.com/1111.html\">post</a></p>",
                 post.formatted.for_lj.text
  end

  test "LJ Post with link to another post out of LJ" do
    post1 = create(:post, slug: "post_for_link")
    post = create(:post, text: "This is a [#post|post_for_link]")
    assert_equal "<p>This is a post</p>",
                 post.formatted.for_lj.text
  end

  test "LJ Post with images" do
    p = create(:post, text: "AAA")
    img = create(:image)
    img.observations.first.update_column(:post_id, p.id)
    assert_equal %Q(<p>AAA</p>\n<p><img src="http://localhost/photos/#{img.slug}.jpg" title="House Sparrow" alt="House Sparrow" /><br />\nHouse Sparrow <i>(Passer domesticus)</i></p>),
                 p.formatted.for_lj.text
  end

  test "do not strip wiki tags from comment" do
    comment = create(:comment, text: "Aaa [Blue Tit|parcae]")
    assert_equal "<p>Aaa <a href=\"/species/Parus_caeruleus\">Blue Tit</a></p>",
                 comment.formatted.text
  end

  test "LJ user in site post" do
    p = create(:post, text: "LJ user [@stonechat|lj]")
    assert_equal %Q(<p>LJ user <span class="ljuser" style="white-space: nowrap;"><a href="http://stonechat.livejournal.com/profile" rel="nofollow"><img src="http://p-stat.livejournal.com/img/userinfo.gif" alt="info" width="17" height="17" style="vertical-align: bottom; border: 0; padding-right: 1px;" /></a><a href="http://stonechat.livejournal.com/" rel="nofollow"><b>stonechat</b></a></span></p>),
                 p.formatted.for_site.text
  end

  test "LJ user in LJ post" do
    p = create(:post, text: "LJ user [@stonechat|lj]")
    assert_equal %Q(<p>LJ user <lj user="stonechat"></p>),
                 p.formatted.for_lj.text
  end

  test "Voron vs vorona" do
    p = create(:post, text: "[вОрон|Corvus corax]")
    assert_equal %Q(<p><a href=\"/species/Corvus_corax\" class=\"sp_link\">во&#769;рон</a></p>),
                 p.formatted.for_site.text
  end

end
