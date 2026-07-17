# frozen_string_literal: true

require "test_helper"

class PostsHelperTest < ActionView::TestCase
  include ImagesHelper # post_cover_image_url builds the url through static_jpg_url

  # The site's default locale (uk) has no URL prefix; other languages do.
  # Cyrillic posts (uk, ru) live in the unprefixed section, English ones under /en.

  test "post_link renders a link to the post" do
    post = create(:post, lang: "uk")

    result = post_link("Read it", post)

    assert_includes result, ">Read it</a>"
    assert_includes result, post.post_core.slug
  end

  test "post_link marks a non-public post as grayed out" do
    post = create(:post, status: "PRIV")

    assert_includes post_link("Read it", post), %(class="grayout")
  end

  test "post_link does not gray out a public post" do
    post = create(:post, status: "OPEN")

    assert_not_includes post_link("Read it", post), "grayout"
  end

  test "post_link without a post renders nothing by default" do
    assert_nil post_link("Read it", nil)
  end

  test "post_link without a post can fall back to plain text" do
    assert_equal "Read it", post_link("Read it", nil, true)
  end

  test "post_link accepts options as the third argument" do
    post = create(:post, lang: "uk")

    result = post_link("Read it", post, { locale: :en })

    assert_includes result, "/en/"
  end

  test "default_public_post_path leaves a cyrillic post unprefixed" do
    assert_not_includes default_public_post_path(create(:post, lang: "uk")), "/uk/"
    assert_not_includes default_public_post_path(create(:post, lang: "ru")), "/ru/"
  end

  test "default_public_post_path prefixes an English post" do
    assert_includes default_public_post_path(create(:post, lang: "en")), "/en/"
  end

  test "default_public_post_url prefixes an English post but not a cyrillic one" do
    assert_includes default_public_post_url(create(:post, lang: "en")), "/en/"
    assert_not_includes default_public_post_url(create(:post, lang: "ru")), "/ru/"
  end

  test "localized_public_post_path distinguishes uk from ru, unlike the default path" do
    ru_post = create(:post, lang: "ru")

    # default_public_post_path lumps both cyrillic languages into the unprefixed section
    assert_not_includes default_public_post_path(ru_post), "/ru/"
    # localized_public_post_path keeps ru in its own section
    assert_includes localized_public_post_path(ru_post), "/ru/"
  end

  test "localized_public_post_path leaves the default locale unprefixed" do
    assert_not_includes localized_public_post_path(create(:post, lang: "uk")), "/uk/"
  end

  test "post_lang_classes marks a post written in another language" do
    I18n.with_locale(:uk) do
      assert_equal :diff_lang, post_lang_classes(create(:post, lang: "en"))
    end
  end

  test "post_lang_classes returns nothing for a post in the current language" do
    I18n.with_locale(:uk) do
      assert_nil post_lang_classes(create(:post, lang: "uk"))
    end
  end

  test "post_cover_image_url returns an external cover image as is" do
    post = create(:post, post_core: create(:post_core, cover_image_slug: "https://example.com/cover.jpg"))

    assert_equal "https://example.com/cover.jpg", post_cover_image_url(post)
  end

  test "post_cover_image_url looks a local cover image up by slug" do
    image = create(:image)
    post = create(:post, post_core: create(:post_core, cover_image_slug: image.slug))

    # The url itself is built by static_jpg_url, which needs a real request context;
    # here we only check that the slug resolves to the image rather than being
    # returned verbatim the way an external URL is.
    assert_not_equal image.slug, post_cover_image_url(post)
    assert_not_nil post_cover_image_url(post)
  end

  test "post_cover_image_url returns nothing without a cover image" do
    assert_nil post_cover_image_url(create(:post))
  end
end
