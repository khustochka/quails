require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  setup do
    @video = create(:video)
  end

  test "should get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:videos)
  end

  test "should get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "should create video" do
    login_as_admin
    assert_difference('Video.count') do
      post :create, video: { description: "", slug: 'new_video', title: "new_title", url: "http://yyy.com/fake" }
    end

    assert_redirected_to video_path(assigns(:video))
  end

  test "should show video" do
    get :show, id: @video
    assert_response :success
  end

  test "should get edit" do
    login_as_admin
    get :edit, id: @video
    assert_response :success
  end

  test "should update video" do
    login_as_admin
    patch :update, id: @video, video: { description: @video.description, slug: @video.slug, title: @video.title, url: @video.url }
    assert_redirected_to video_path(assigns(:video))
  end

  test "should destroy video" do
    login_as_admin
    assert_difference('Video.count', -1) do
      delete :destroy, id: @video
    end

    assert_redirected_to videos_path
  end
end
