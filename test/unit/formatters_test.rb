# frozen_string_literal: true

require "test_helper"

class FormattersTest < ActionDispatch::IntegrationTest
  include ImagesHelper

  test "no span_caps by default" do
    assert_equal "xxx ABC xxx", OneLineFormatter.apply("xxx ABC xxx")
  end

  test "Russian double quotes" do
    assert_equal "Новый «лайфер»", OneLineFormatter.apply('Новый "лайфер"')
  end

  test "Post with species link" do
    post = build(:post, body: "This is a {{Wryneck|jyntor}}")
    assert_equal "<p>This is a <a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>",
      post.decorated.for_site.body
  end

  test "Post with species link and English translation" do
    post = build(:post, body: "This is a {{Вертишейка|jyntor|en}}")
    assert_equal "<p>This is a <a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Вертишейка</a> (Wryneck)</p>",
      post.decorated.for_site.body
  end

  test "Post with unknown species" do
    post = build(:post, body: "This is a {{Frodo hobbitana}}")
    assert_equal "<p>This is a <i class=\"sci_name\">Frodo hobbitana</i></p>",
      post.decorated.for_site.body
  end

  test "Post with link to another post" do
    post1 = create(:post, slug: "post_for_link")
    post = build(:post, body: "This is a {{#post|post_for_link}}")
    assert_equal "<p>This is a <a href=\"/#{post1.year}/#{post1.month}/post_for_link\">post</a></p>",
      post.decorated.for_site.body
  end

  test "Post with photo by slug" do
    image = create(:image)
    post = build(:post, body: "{{^#{image.slug}}}")
    assert_includes post.decorated.for_site.body,
      "<a href=\"/photos/#{image.slug}\"><img src=\"#{jpg_url(image)}\" title=\"[photo]\" alt=\"[photo]\" /></a>"
    assert_includes post.decorated.for_site.body,
      "<figcaption class=\"imagetitle\"><a href=\"/photos/#{image.slug}\">House Sparrow</a></figcaption>"
  end

  test "Post with video by slug" do
    video = create(:video)
    post = build(:post, body: "{{&#{video.slug}}}")
    txt = post.decorated.for_site.body
    assert_match(/<div class=\"video-container\">\s*<iframe/, txt)
    assert_includes txt,
      "src=\"#{video.large.url}\""
    assert_includes txt, "Youtube"
    # No linebreak after span, meaning html was properly processed by textile.
    assert_not_includes txt, "<span class=\"yt_link\"><br"
  end

  test "Invalid image wiki tag should not raise exception" do
    post = build(:post, body: "{{^sdfgdfsgsdfgdfsgdf}}")
    assert_equal "",
      post.decorated.for_site.body
  end

  test "LJ Post with species link" do
    post = build(:post, body: "This is a {{Wryneck|jyntor}}")
    assert_equal "<p>This is a <b title=\"Jynx torquilla\">Wryneck</b></p>",
      post.decorated.for_lj.body
  end

  test "LJ Post with unknown species" do
    post = build(:post, body: "This is a {{Frodo hobbitana}}")
    assert_equal "<p>This is a <i class=\"sci_name\">Frodo hobbitana</i></p>",
      post.decorated.for_lj.body
  end

  test "LJ Post with link to another post in LJ" do
    Settings.create(key: "lj_user", value: { name: "stonechat" })
    url = "http://stonechat.livejournal.com/1111.html"
    post1 = create(:post,
      slug: "post_for_link",
      lj_data: Post::LJData.new("1111", "http://stonechat.livejournal.com/1111.html"))
    post = build(:post, body: "This is a {{#post|post_for_link}}")
    assert_equal "<p>This is a <a href=\"#{url}\">post</a></p>",
      post.decorated.for_lj.body
  end

  test "LJ Post with link to another post out of LJ" do
    post1 = build(:post, slug: "post_for_link")
    post = build(:post, body: "This is a {{#post|post_for_link}}")
    assert_equal "<p>This is a post</p>",
      post.decorated.for_lj.body
  end

  test "LJ Post with photo by slug" do
    image = create(:image)
    post = build(:post, body: "{{^#{image.slug}}}")
    assert_includes post.decorated({ host: "localhost", port: 3011 }).for_lj.body,
      "<img src=\"https://localhost:3011/photos/#{image.slug}.jpg\" title=\"[photo]\" alt=\"[photo]\" />"
    assert_includes post.decorated({ host: "localhost", port: 3011 }).for_lj.body,
      "<figcaption class=\"imagetitle\">\nHouse Sparrow <i>(Passer domesticus)</i>\n</figcaption>"
  end

  test "LJ Post with S3 image" do
    image = create(:image_on_storage)
    post = build(:post, body: "{{^#{image.slug}}}")
    assert_includes post.decorated({ host: "localhost", port: 3011 }).for_lj.body,
      "<img src=\"https://localhost:3011/photos/#{image.slug}.jpg\" title=\"[photo]\" alt=\"[photo]\" />"
    assert_includes post.decorated({ host: "localhost", port: 3011 }).for_lj.body,
      "<figcaption class=\"imagetitle\">\nHouse Sparrow <i>(Passer domesticus)</i>\n</figcaption>"
  end

  test "LJ Post with images" do
    p = create(:post, body: "AAA")
    image = create(:image)
    image.card.update_column(:post_id, p.id)
    assert_includes p.decorated({ host: "localhost", port: 3011 }).for_lj.body,
      "<img src=\"https://localhost:3011/photos/#{image.slug}.jpg\" title=\"[photo]\" alt=\"[photo]\" />"
    assert_includes p.decorated({ host: "localhost", port: 3011 }).for_lj.body,
      "<figcaption class=\"imagetitle\">\nHouse Sparrow <i>(Passer domesticus)</i>\n</figcaption>"
  end

  test "do not strip wiki tags from comment" do
    comment = build(:comment, body: "Aaa {{Wryneck|jyntor}}")
    assert_equal "<p>Aaa <a href=\"/species/Jynx_torquilla\">Wryneck</a></p>",
      comment.decorated.body
  end

  test "LJ user in site post" do
    p = build(:post, body: "LJ user {{@stonechat|lj}}")
    assert_equal '<p>LJ user <span class="ljuser" style="white-space: nowrap;"><a href="https://stonechat.livejournal.com/profile" rel="nofollow"><img src="http://p-stat.livejournal.com/img/userinfo.gif" alt="info" width="17" height="17" style="vertical-align: bottom; border: 0; padding-right: 1px;" /></a><a href="http://stonechat.livejournal.com/" rel="nofollow"><b>stonechat</b></a></span></p>',
      p.decorated.for_site.body
  end

  test "LJ user in LJ post" do
    p = build(:post, body: "LJ user {{@stonechat|lj}}")
    assert_equal '<p>LJ user <lj user="stonechat"></p>',
      p.decorated.for_lj.body
  end

  test "Voron vs vorona" do
    # Mimic sparrow as a raven not to create more fixtures
    p = build(:post, body: "{{вОрон|Passer domesticus}}")
    assert_equal '<p><a class="sp_link" href="/species/Passer_domesticus">во&#769;рон</a></p>',
      p.decorated.for_site.body
  end

  test "Feed entry with species link" do
    post = build(:post, body: "This is a {{Wryneck|jyntor}}")
    assert_equal "<p>This is a <a class=\"sp_link\" href=\"https://localhost:3011/species/Jynx_torquilla\">Wryneck</a></p>",
      post.decorated({ host: "localhost", port: 3011 }).for_feed.body
  end
end
