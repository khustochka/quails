require "test_helper"

class CorrectionsControllerTest < ActionController::TestCase
  setup do
    @correction = create(:correction)
  end

  test "is not accessible by non-admin" do
    assert_raises ActionController::RoutingError do
      get :index
    end
  end

  test "should get index" do
    login_as_admin
    get :index
    assert_response :success
  end

  test "should get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "should create correction" do
    login_as_admin
    assert_difference("Correction.count") do
      post :create, params: { correction: { model_classname: @correction.model_classname, query: @correction.query, sort_column: @correction.sort_column } }
    end

    assert_redirected_to edit_correction_url(Correction.last)
  end

  test "start redirects you to the first instance matching the query" do
    post1 = create(:post, body: "Link http://google.com", face_date: "2022-08-02")
    post2 = create(:post, body: "Link https://google.com", face_date: "2022-08-01")
    post3 = create(:post, body: "Link http://flickr.com", face_date: "2022-07-29")
    login_as_admin
    get :start, params: { id: @correction.id }
    assert_redirected_to edit_post_path(post3, correction: @correction.id)
  end

  test "when there are no records, start redirects you to the correction page with a flash message" do
    login_as_admin
    get :start, params: { id: @correction.id }
    assert_redirected_to edit_correction_url(@correction)
    assert_equal "You have reached the last record!", flash[:notice]
  end

  test "should get edit" do
    login_as_admin
    get :edit, params: { id: @correction.id }
    assert_response :success
  end

  test "should update correction" do
    login_as_admin
    patch :update, params: { id: @correction.id, correction: { model_classname: @correction.model_classname, query: @correction.query, sort_column: @correction.sort_column } }
    assert_redirected_to edit_correction_url(@correction)
  end

  test "should destroy correction" do
    login_as_admin
    assert_difference("Correction.count", -1) do
      delete :destroy, params: { id: @correction.id }
    end

    assert_redirected_to corrections_url
  end
end
