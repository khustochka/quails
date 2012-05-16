require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "create post" do
    assert_difference('Post.count') do
      login_as_admin
      post :create, post: build(:post).attributes
    end
    assert_redirected_to public_post_path(assigns(:post))
  end

  test "show post" do
    blogpost = create(:post)
    get :show, blogpost.to_url_params
    assert_response :success
  end

  # TODO: Unreliable test?
  test "species list in the post properly ordered" do
    # Dummy swap of two species
    max_index = Species.maximum(:index_num)
    sp1 = Species.find_by_index_num(10)
    sp1.update_attributes(index_num: max_index + 1)
    sp2 = Species.find_by_index_num(max_index)
    sp2.update_attributes(index_num: 10)

    blogpost = create(:post)
    create(:observation, species: sp2, post: blogpost)
    create(:observation, species: sp1, post: blogpost)

    get :show, blogpost.to_url_params
    assigns(:post).species.should == [sp2, sp1]
  end

  test "get edit" do
    blogpost = create(:post)
    login_as_admin
    get :edit, id: blogpost.to_param
    assert_response :success
    assert_select "a[href=#{public_post_path(blogpost)}]", true
  end

  test "update post" do
    blogpost = create(:post)
    blogpost.title = 'Changed title'
    login_as_admin
    put :update, id: blogpost.to_param, post: blogpost.attributes
    assert_redirected_to public_post_path(assigns(:post))
  end

  test "do not update post with invalid attribute" do
    blogpost = create(:post)
    blogpost.title = ''
    login_as_admin
    put :update, id: blogpost.to_param, post: blogpost.attributes
    assert_template :edit
  end

  test "do not update post with invalid slug" do
    blogpost = create(:post)
    blogpost2 = blogpost.dup
    blogpost2.slug = ''
    login_as_admin
    put :update, id: blogpost.slug, post: blogpost2.attributes
    assert_template :edit
    assert_select "form[action=#{post_path(blogpost)}]"
  end

  test "destroy post" do
    blogpost = create(:post)
    assert_difference('Post.count', -1) do
      login_as_admin
      delete :destroy, id: blogpost.to_param
    end
    assert_redirected_to blog_url
  end

  test "redirect post to correct URL if year and month are incorrect" do
    blogpost = create(:post, face_date: '2007-12-06 13:14:15')
    get :show, {id: blogpost.slug, year: 2010, month: '01'}
    assert_redirected_to public_post_path(blogpost)
    assert_response 301
  end

  # HTTP auth tests

  test 'protect new with HTTP authentication' do
    assert_raises(ActionController::RoutingError) { get :new }
    #assert_response 404
  end

  test 'protect edit with HTTP authentication' do
    blogpost = create(:post)
    assert_raises(ActionController::RoutingError) { get :edit, id: blogpost.to_param }
    #assert_response 404
  end

  test 'protect create with HTTP authentication' do
    blogpost = create(:post)
    assert_raises(ActionController::RoutingError) { post :create, post: blogpost.attributes }
    #assert_response 404
  end

  test 'protect update with HTTP authentication' do
    blogpost = create(:post)
    blogpost.title = 'Changed title'
    assert_raises(ActionController::RoutingError) do
      put :update, id: blogpost.to_param, post: blogpost.attributes
    end
    #assert_response 404
  end

  test 'protect destroy with HTTP authentication' do
    blogpost = create(:post)
    assert_raises(ActionController::RoutingError) { delete :destroy, id: blogpost.to_param }
    #assert_response 404
  end

  test 'proper link options' do
    blogpost = create(:post)
    public_post_path(blogpost, anchor: 'comments').should == show_post_path(blogpost.to_url_params.merge({anchor: 'comments'}))
  end
end
