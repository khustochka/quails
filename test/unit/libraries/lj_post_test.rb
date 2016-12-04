require "test_helper"

class LJPostTest < ActiveSupport::TestCase

  include ImagesHelper

  test "LJ Post with species link" do
    post = build(:post, text: "This is a {{Wryneck|jyntor}}")
    assert_equal "<p>This is a <b title=\"Jynx torquilla\">Wryneck</b></p>",
                 LJPost.new(post).text
  end

  test "LJ Post with unknown species" do
    post = build(:post, text: "This is a {{Frodo hobbitana}}")
    assert_equal "<p>This is a <i class=\"sci_name\">Frodo hobbitana</i></p>",
                 LJPost.new(post).text
  end

  test "LJ Post with link to another post in LJ" do
    Settings.create(key: 'lj_user', value: {name: 'stonechat'})
    url = "http://stonechat.livejournal.com/1111.html"
    post1 = create(:post,
                   slug: "post_for_link",
                   lj_data: Post::LJData.new("1111", "http://stonechat.livejournal.com/1111.html"))
    post = build(:post, text: "This is a {{#post|post_for_link}}")
    assert_equal "<p>This is a <a href=\"#{url}\">post</a></p>",
                 LJPost.new(post).text
  end

  test "LJ Post with link to another post out of LJ" do
    post1 = build(:post, slug: "post_for_link")
    post = build(:post, text: "This is a {{#post|post_for_link}}")
    assert_equal "<p>This is a post</p>",
                 LJPost.new(post).text
  end

  test "LJ Post with photo by slug" do
    image = create(:image)
    post = build(:post, text: "{{^#{image.slug}}}")
    lj_post = LJPost.new(post)
    assert_includes lj_post.text,
                    "<img src=\"#{jpg_url(image)}\" title=\"[photo]\" alt=\"[photo]\" />"
    assert_includes lj_post.text,
                    "<figcaption class=\"imagetitle\">\nHouse Sparrow <i>(Passer domesticus)</i>\n</figcaption>"
  end

  test "LJ Post with images" do
    post = create(:post, text: "AAA")
    lj_post = LJPost.new(post)
    image = create(:image)
    image.card.update_column(:post_id, post.id)
    assert_includes lj_post.text,
                    "<img src=\"#{jpg_url(image)}\" title=\"[photo]\" alt=\"[photo]\" />"
    assert_includes lj_post.text,
                    "<figcaption class=\"imagetitle\">\nHouse Sparrow <i>(Passer domesticus)</i>\n</figcaption>"

  end
  
  test "LJ user in LJ post" do
    post = build(:post, text: "LJ user {{@stonechat|lj}}")
    lj_post = LJPost.new(post)
    assert_equal %Q(<p>LJ user <lj user="stonechat"></p>),
                 lj_post.text
  end

end
