require 'test_helper'

class FeedsControllerTest < ActionController::TestCase

  test 'empty blog atom feed is not failing' do
    get :blog, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'get blog atom feed' do
    create(:post)
    create(:post)
    create(:post)

    get :blog, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
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

  test 'get sitemap' do
    create(:post)
    create(:post)
    create(:post, status: 'PRIV')

    get :sitemap, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
    assigns(:posts).size.should == 2
  end

end
