# frozen_string_literal: true

require "test_helper"

class FeedsControllerTest < ActionController::TestCase

  test "empty blog atom feed is not failing" do
    get :blog, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

  test "get blog atom feed with images" do
    create(:post)
    create(:post)
    create(:image, observations: [create(:observation, card: create(:card, post: create(:post)))])
    get :blog, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

  test "feed updated time should be correct (in local TZ)" do
    create(:post)
    create(:post)
    p3 = create(:post)

    get :blog, format: :xml
    assert_select "feed>updated", p3.updated_at.iso8601
    assert_select "entry>published", Time.zone.parse(p3.read_attribute(:face_date).strftime("%F %T")).iso8601
  end

  test "empty photos atom feed is not failing" do
    get :photos, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

  test "blog feed does not contain relative links" do
    create(:post)
    create(:post)
    create(:image, observations: [create(:observation, card: create(:card, post: create(:post)))])
    get :blog, format: :xml
    links = response.body.scan(/\w+="\/[^"]+"/)
    assert_empty links, "Relative links found: #{links.join(", ")}"
  end

  test "get photos atom feed" do
    create(:image)
    create(:image)
    create(:image)

    get :photos, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

  test "photos feed does not contain relative links" do
    create(:image)
    create(:image)
    create(:image)

    get :photos, format: :xml
    links = response.body.scan(/\w+="\/[^"]+"/)
    assert_empty links, "Relative links found: #{links.join(", ")}"
  end

  test "photos feed should include photos and videos" do
    im1 = create(:image)
    vi1 = create(:video)
    im2 = create(:image)

    get :photos, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
    assert_select "link[href='#{url_for(im1)}']"
    assert_select "link[href='#{url_for(im2)}']"
    assert_select "link[href='#{url_for(vi1)}']"
  end

  test "photos feed should contain full urls for S3 images" do
    im1 = create(:image_on_storage)

    get :photos, format: :xml
    assert_response :success
    doc = Nokogiri::XML(response.body)
    html = Nokogiri::HTML(doc.css("entry content").text)
    src = html.css("img").first[:src]
    assert_match(/^http/, src)
  end

  test "photos feed should contain full url to species page" do
    im1 = create(:image_on_storage)

    get :photos, format: :xml
    assert_response :success
    doc = Nokogiri::XML(response.body)
    html = Nokogiri::HTML(doc.css("entry content").text)
    src = html.css("a.sp_link").first[:href]
    assert_match(/^http/, src)
  end

  test "empty sitemap is not failing" do
    get :sitemap, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

  test "get sitemap, do not include PRIVATE and NOINDEX posts" do
    create(:post)
    create(:post)
    create(:post, status: "PRIV")
    create(:post, status: "NIDX")

    get :sitemap, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
    assert_equal 2, assigns(:posts).size
  end

  test "sitemap with images" do
    FactoryBot.create(:image)
    get :sitemap, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

  test "sitemap feed does not contain relative links" do
    create(:post)
    FactoryBot.create(:image)

    get :sitemap, format: :xml
    links = response.body.scan(/\w+="\/[^"]+"/)
    assert_empty links, "Relative links found: #{links.join(", ")}"
  end

  test "instant articles feed" do
    create(:post, publish_to_facebook: true)
    create(:post, publish_to_facebook: true)
    get :instant_articles, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

  test "instant articles feed does not contain relative links" do
    create(:post, publish_to_facebook: true)
    create(:post, publish_to_facebook: true)
    get :instant_articles, format: :xml
    assert_response :success
    links = response.body.scan(/\w+="\/[^"]+"/)
    assert_empty links, "Relative links found: #{links.join(", ")}"
  end

  test "instant article feed with images" do
    create(:post, publish_to_facebook: true)
    create(:post, publish_to_facebook: true)
    create(:image, observations: [create(:observation, card: create(:card, post: create(:post)))])
    get :instant_articles, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

  test "instant article feed with embedded images" do
    post1 = create(:post, publish_to_facebook: true)
    create(:post, publish_to_facebook: true)
    img = create(:image, observations: [create(:observation, card: create(:card, post: create(:post)))])
    post1.update(text: post1.text + "\n{{^#{img.slug}}}\n")
    get :instant_articles, format: :xml
    assert_response :success
    assert_equal Mime[:xml], response.media_type
  end

end
