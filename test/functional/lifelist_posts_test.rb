require 'test_helper'

class LifelistPostsTest < ActionController::TestCase
  tests LifelistController

  setup do
    @obs = [
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-06-20", :locus => seed(:new_york)),
        FactoryGirl.create(:observation, :species => seed(:anacly), :observ_date => "2007-07-18", :locus => seed(:brovary)),
        FactoryGirl.create(:observation, :species => seed(:embcit), :observ_date => "2009-08-09", :locus => seed(:kherson)),
        FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2010-06-18"),
        FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2009-06-18")
    ]
  end

  test 'show post link on default lifelist if post is associated' do
    @obs[1].post = FactoryGirl.create(:post)
    @obs[1].save!
    get :default
    assert_response :success
    lifers = assigns(:lifers)
    lifers.map(&:post).compact.size.should == 1
    assert_select "a[href=#{public_post_path(@obs[1].post)}]"
  end

  test 'show post link on lifelist ordered by taxonomy if post is associated' do
    @obs[1].post = FactoryGirl.create(:post)
    @obs[1].save!
    get :by_taxonomy
    assert_response :success
    lifers = assigns(:lifers)
    lifers.map(&:post).compact.size.should == 1
    assert_select "a[href=#{public_post_path(@obs[1].post)}]"
  end

  test 'do not show post link if no post is associated' do
    @obs[3].post = FactoryGirl.create(:post)
    @obs[3].save!
    get :default
    assert_response :success
    lifers = assigns(:lifers)
    lifers.select {|s| s.code == 'anapla'}[0].post.should be_nil
  end

  test 'do not show hidden post link to common visitor' do
    @obs[1].post = FactoryGirl.create(:post, :status => 'PRIV')
    @obs[1].save!
    get :default
    assert_response :success
    lifers = assigns(:lifers)
    lifers.map(&:post).compact.should be_empty
  end

  test 'show hidden post link to administrator' do
    @obs[1].post = FactoryGirl.create(:post, :status => 'PRIV')
    @obs[1].save!
    login_as_admin
    get :default
    assert_response :success
    lifers = assigns(:lifers)
    lifers.map(&:post).compact.size.should == 1
    assert_select "a[href=#{public_post_path(@obs[1].post)}]"
  end
end
