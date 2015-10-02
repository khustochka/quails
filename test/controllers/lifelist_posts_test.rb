require 'test_helper'

class LifelistPostsTest < ActionController::TestCase
  tests ListsController

  setup do
    @obs = [
        create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: seed(:new_york))),
        create(:observation, species: seed(:anacly), card: create(:card, observ_date: "2007-07-18", locus: seed(:brovary))),
        create(:observation, species: seed(:embcit), card: create(:card, observ_date: "2009-08-09", locus: seed(:kherson))),
        create(:observation, species: seed(:anapla), card: create(:card, observ_date: "2010-06-18")),
        create(:observation, species: seed(:anapla), card: create(:card, observ_date: "2009-06-18"))
    ]
  end

  test 'show post link on default lifelist if post is associated' do
    @obs[1].post = create(:post)
    @obs[1].save!
    get :basic
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal 1, lifers.to_a.map(&:post).compact.size
    assert_select "a[href='#{public_post_path(@obs[1].post)}']"
  end

  test 'do show post link if locale is not Russian' do
    @obs[1].post = create(:post)
    @obs[1].save!
    get :basic, locale: :en
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal nil, lifers.to_a.find {|s| s.species.code == 'anacly'}.main_post
  end

  test 'show post link on lifelist ordered by taxonomy if post is associated' do
    @obs[1].post = create(:post)
    @obs[1].save!
    get :basic, sort: :by_taxonomy
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal 1, lifers.to_a.map(&:post).compact.size
    assert_select "a[href='#{public_post_path(@obs[1].post)}']"
  end

  test 'do not show post link if no post is associated' do
    @obs[3].post = create(:post)
    @obs[3].save!
    get :basic
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal nil, lifers.to_a.find {|s| s.species.code == 'anapla'}.post
  end

  test 'do not show hidden post link to common visitor' do
    @obs[1].post = create(:post, status: 'PRIV')
    @obs[1].save!
    get :basic
    assert_response :success
    lifers = assigns(:lifelist)
    assert_empty lifers.to_a.map(&:post).compact
  end

  test 'show hidden post link to administrator' do
    @obs[1].post = create(:post, status: 'PRIV')
    @obs[1].save!
    login_as_admin
    get :basic
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal 1, lifers.to_a.map(&:post).compact.size
    assert_select "a[href='#{public_post_path(@obs[1].post)}']"
  end
end
