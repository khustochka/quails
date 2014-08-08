# -- encoding: utf-8 --

require 'test_helper'

class FormattersTest < ActionView::TestCase

  include ImagesHelper

  test "no span_caps by default" do
    assert_equal "xxx ABC xxx", OneLineFormatter.apply("xxx ABC xxx")
  end

  test "Russian double quotes" do
    assert_equal 'Новый &#171;лайфер&#187;', OneLineFormatter.apply('Новый "лайфер"')
  end

  test "Post with species link" do
    post = build(:post, text: "This is a {{Blue Tut|parcae}}")
    assert_equal "<p>This is a <a href=\"/species/Parus_caeruleus\" class=\"sp_link\">Blue Tut</a></p>",
                 post.formatted.for_site.text
  end

  test "Post with unknown species" do
    post = build(:post, text: "This is a {{Frodo hobbitana}}")
    assert_equal "<p>This is a <i class=\"sci_name\">Frodo hobbitana</i></p>",
                 post.formatted.for_site.text
  end

  test "Post with link to another post" do
    post1 = create(:post, slug: "post_for_link")
    post = build(:post, text: "This is a {{#post|post_for_link}}")
    assert_equal "<p>This is a <a href=\"/#{post1.year}/#{post1.month}/post_for_link\">post</a></p>",
                 post.formatted.for_site.text
  end

  test "Post with photo by slug" do
    image = create(:image)
    post = build(:post, text: "{{^#{image.slug}}}")
    assert_includes post.formatted.for_site.text,
                    "<a href=\"/photos/#{image.slug}\"><img src=\"#{jpg_url(image)}\" title=\"[photo]\" alt=\"[photo]\" /></a>"
    assert_includes post.formatted.for_site.text,
                    "<figcaption class=\"imagetitle\"><a href=\"/photos/#{image.slug}\">House Sparrow</a></figcaption>"

  end

  test "Invalid image wiki tag should not raise exception" do
    post = build(:post, text: "{{^sdfgdfsgsdfgdfsgdf}}")
    assert_equal "",
                 post.formatted.for_site.text
  end

  test "LJ Post with species link" do
    post = build(:post, text: "This is a {{Blue Tut|parcae}}")
    assert_equal "<p>This is a <b title=\"Parus caeruleus\">Blue Tut</b></p>",
                 post.formatted.for_lj.text
  end

  test "LJ Post with unknown species" do
    post = build(:post, text: "This is a {{Frodo hobbitana}}")
    assert_equal "<p>This is a <i class=\"sci_name\">Frodo hobbitana</i></p>",
                 post.formatted.for_lj.text
  end

  test "LJ Post with link to another post in LJ" do
    Settings.create(key: 'lj_user', value: {name: 'stonechat'})
    url = "http://stonechat.livejournal.com/1111.html"
    post1 = create(:post,
                   slug: "post_for_link",
                   lj_data: Hashie::Mash.new({post_id: "1111", url: "http://stonechat.livejournal.com/1111.html"}))
    post = build(:post, text: "This is a {{#post|post_for_link}}")
    assert_equal "<p>This is a <a href=\"#{url}\">post</a></p>",
                 post.formatted.for_lj.text
  end

  test "LJ Post with link to another post out of LJ" do
    post1 = build(:post, slug: "post_for_link")
    post = build(:post, text: "This is a {{#post|post_for_link}}")
    assert_equal "<p>This is a post</p>",
                 post.formatted.for_lj.text
  end

  test "LJ Post with photo by slug" do
    image = create(:image)
    post = build(:post, text: "{{^#{image.slug}}}")
    assert_includes post.formatted.for_lj.text,
                    "<img src=\"#{jpg_url(image)}\" title=\"[photo]\" alt=\"[photo]\" />"
    assert_includes post.formatted.for_lj.text,
                    "<figcaption class=\"imagetitle\">\nHouse Sparrow <i>(Passer domesticus)</i>\n</figcaption>"
  end

  test "LJ Post with images" do
    p = create(:post, text: "AAA")
    image = create(:image)
    image.card.update_column(:post_id, p.id)
    assert_includes p.formatted.for_lj.text,
                    "<img src=\"#{jpg_url(image)}\" title=\"[photo]\" alt=\"[photo]\" />"
    assert_includes p.formatted.for_lj.text,
                    "<figcaption class=\"imagetitle\">\nHouse Sparrow <i>(Passer domesticus)</i>\n</figcaption>"

  end

  test "do not strip wiki tags from comment" do
    comment = build(:comment, text: "Aaa {{Blue Tit|parcae}}")
    assert_equal "<p>Aaa <a href=\"/species/Parus_caeruleus\">Blue Tit</a></p>",
                 comment.formatted.text
  end

  test "LJ user in site post" do
    p = build(:post, text: "LJ user {{@stonechat|lj}}")
    assert_equal %Q(<p>LJ user <span class="ljuser" style="white-space: nowrap;"><a href="http://stonechat.livejournal.com/profile" rel="nofollow"><img src="http://p-stat.livejournal.com/img/userinfo.gif" alt="info" width="17" height="17" style="vertical-align: bottom; border: 0; padding-right: 1px;" /></a><a href="http://stonechat.livejournal.com/" rel="nofollow"><b>stonechat</b></a></span></p>),
                 p.formatted.for_site.text
  end

  test "LJ user in LJ post" do
    p = build(:post, text: "LJ user {{@stonechat|lj}}")
    assert_equal %Q(<p>LJ user <lj user="stonechat"></p>),
                 p.formatted.for_lj.text
  end

  test "Voron vs vorona" do
    p = build(:post, text: "{{вОрон|Corvus corax}}")
    assert_equal %Q(<p><a href=\"/species/Corvus_corax\" class=\"sp_link\">во&#769;рон</a></p>),
                 p.formatted.for_site.text
  end

end
