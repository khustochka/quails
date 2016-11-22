require 'test_helper'

class FeedsControllerTest < ActionController::TestCase

  test 'empty blog atom feed is not failing' do
    get :blog, params: {format: :xml}
    assert_response :success
    assert_equal Mime[:xml], response.content_type
  end

  test 'get blog atom feed with images' do
    create(:post)
    create(:post)
    create(:image, observations: [create(:observation, card: create(:card, post: create(:post)))])
    get :blog, params: {format: :xml}
    assert_response :success
    assert_equal Mime[:xml], response.content_type
  end

  test 'feed updated time should be correct (in local TZ)' do
    create(:post)
    create(:post)
    p3 = create(:post)

    get :blog, params: {format: :xml}
    assert_select "feed>updated", p3.updated_at.iso8601
    assert_select "entry>published", Time.zone.parse(p3.read_attribute(:face_date).strftime("%F %T")).iso8601
  end

  test 'empty photos atom feed is not failing' do
    get :photos, params: {format: :xml}
    assert_response :success
    assert_equal Mime[:xml], response.content_type
  end

  test 'get photos atom feed' do
    create(:image)
    create(:image)
    create(:image)

    get :photos, params: {format: :xml}
    assert_response :success
    assert_equal Mime[:xml], response.content_type
  end

  test 'photos feed should include photos and videos' do
    im1 = create(:image)
    vi1 = create(:video)
    im2 = create(:image)

    get :photos, params: {format: :xml}
    assert_response :success
    assert_equal Mime[:xml], response.content_type
    assert_select "link[href='#{url_for(im1)}']"
    assert_select "link[href='#{url_for(im2)}']"
    assert_select "link[href='#{url_for(vi1)}']"
  end

  test 'empty sitemap is not failing' do
    get :sitemap, params: {format: :xml}
    assert_response :success
    assert_equal Mime[:xml], response.content_type
  end

  test 'get sitemap, do not include PRIVATE and NOINDEX posts' do
    create(:post)
    create(:post)
    create(:post, status: 'PRIV')
    create(:post, status: 'NIDX')

    get :sitemap, params: {format: :xml}
    assert_response :success
    assert_equal Mime[:xml], response.content_type
    assert_equal 2, assigns(:posts).size
  end

end
