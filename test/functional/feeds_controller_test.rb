require 'test_helper'

class FeedsControllerTest < ActionController::TestCase

  test 'empty blog atom feed is not failing' do
    get :blog, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'get blog atom feed with images' do
    create(:post)
    create(:post)
    create(:image, observations: [create(:observation, card: create(:card, post: create(:post)))])
    get :blog, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'feed updated time should be correct (in local TZ)' do
    create(:post)
    create(:post)
    p3 = create(:post)

    get :blog, format: :xml
    assert_select "feed>updated", p3.updated_at.iso8601
    assert_select "entry>published", Time.zone.parse(p3.read_attribute(:face_date).strftime("%F %T")).iso8601
  end

  test 'empty photos atom feed is not failing' do
    get :photos, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'get photos atom feed' do
    create(:image)
    create(:image)
    create(:image)

    get :photos, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'empty sitemap is not failing' do
    get :sitemap, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'get sitemap, do not include PRIVATE and NOINDEX posts' do
    create(:post)
    create(:post)
    create(:post, status: 'PRIV')
    create(:post, status: 'NIDX')

    get :sitemap, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
    assert_equal 2, assigns(:posts).size
  end

end
