require 'test_helper'

class LifelistControllerTest < ActionController::TestCase

  setup do
    @obs = [
        Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20", :locus => Locus.find_by_code!('new_york')),
        Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18"),
        Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18"),
        Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18", :locus => Locus.find_by_code!('brovary')),
        Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09", :locus => Locus.find_by_code!('kherson'))
    ]
  end

  test "should show full lifelist" do
    get :lifelist
    assert_response :success
    assert_select 'a.sp_link'
  end

  test "should show year list" do
    get :lifelist, :year => 2009
    assert_response :success
    assert_select 'a.sp_link'
  end

  test "should show location list" do
    get :lifelist, :locus => 'new_york'
    assert_response :success
    assert_select 'a.sp_link'
  end

  test "should show lifelist filtered by year and location" do
    get :lifelist, :locus => 'brovary', :year => 2007
    assert_response :success
    assert_select 'a.sp_link'
  end

  test "should show lifelist filtered by year and super location" do
    get :lifelist, :locus => 'ukraine', :year => 2009
    assert_response :success
    assert_select 'a.sp_link'
  end

  should 'show post link if post is associated' do
    @obs[1].post = Factory.create(:post)
    @obs[1].save!
    get :lifelist
    assert_response :success
    assert_select "a[href=#{public_post_path(@obs[1].post)}]", I18n::l(@obs[1].observ_date, :format => :long)
  end

  should 'not show post link if no post is associated' do
    @obs[1].post = Factory.create(:post)
    @obs[1].save!
    get :lifelist
    assert_response :success
    assert_select 'td', I18n::l(@obs[2].observ_date, :format => :long) do
      assert_select 'a', false
    end
  end

  should 'not show hidden post link to common visitor' do
    @obs[1].post = Factory.create(:post, :status => 'PRIV')
    @obs[1].save!
    get :lifelist
    assert_response :success
    assert_select 'td', I18n::l(@obs[1].observ_date, :format => :long) do
      assert_select 'a', false
    end
  end

  should 'show hidden post link to administrator' do
    @obs[1].post = Factory.create(:post, :status => 'PRIV')
    @obs[1].save!
    login_as_admin
    get :lifelist
    assert_response :success
    assert_select "a[href=#{public_post_path(@obs[1].post)}]", I18n::l(@obs[1].observ_date, :format => :long)
  end
end
