require 'test_helper'

class FeedsControllerTest < ActionController::TestCase

  test 'empty blog atom feed is not failing' do
    get :blog, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'get blog atom feed' do
    create(:post, code: 'code1')
    create(:post, code: 'code2')
    create(:post, code: 'code3')

    get :blog, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'empty sitemap is not failing' do
    get :sitemap, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

  test 'get sitemap' do
    create(:post, code: 'code1')
    create(:post, code: 'code2')
    create(:post, code: 'code3', status: 'PRIV')

    get :sitemap, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
    assigns(:posts).size.should == 2
  end

end