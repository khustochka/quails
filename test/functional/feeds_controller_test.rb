require 'test_helper'

class FeedsControllerTest < ActionController::TestCase

  test 'get blog atom feed' do

    create(:post, code: 'code1')
    create(:post, code: 'code2')
    create(:post, code: 'code3')

    get :blog, format: :xml
    assert_response :success
    assert_equal Mime::XML, response.content_type
  end

end