require 'test_helper'

class LifelistPostsTest < ActionController::TestCase
  tests LifelistController

  setup do
    @obs = [
        FactoryGirl.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20", :locus => Locus.find_by_code!('new_york')),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18"),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18"),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18", :locus => Locus.find_by_code!('brovary')),
        FactoryGirl.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09", :locus => Locus.find_by_code!('kherson'))
    ]
  end

  #test 'show post link if post is associated' do
  #  @obs[1].post = FactoryGirl.create(:post)
  #  @obs[1].save!
  #  get :lifelist
  #  assert_response :success
  #  assert_select "a[href=#{public_post_path(@obs[1].post)}]", I18n::l(@obs[1].observ_date, :format => :long)
  #end
  #
  #test 'do not show post link if no post is associated' do
  #  @obs[1].post = FactoryGirl.create(:post)
  #  @obs[1].save!
  #  get :lifelist
  #  assert_response :success
  #  assert_select 'time', I18n::l(@obs[2].observ_date, :format => :long) do
  #    assert_select 'a', false
  #  end
  #end
  #
  #test 'do not show hidden post link to common visitor' do
  #  @obs[1].post = FactoryGirl.create(:post, :status => 'PRIV')
  #  @obs[1].save!
  #  get :lifelist
  #  assert_response :success
  #  assert_select 'time', I18n::l(@obs[1].observ_date, :format => :long) do
  #    assert_select 'a', false
  #  end
  #end
  #
  #test 'show hidden post link to administrator' do
  #  @obs[1].post = FactoryGirl.create(:post, :status => 'PRIV')
  #  @obs[1].save!
  #  login_as_admin
  #  get :lifelist
  #  assert_response :success
  #  assert_select "a[href=#{public_post_path(@obs[1].post)}]", I18n::l(@obs[1].observ_date, :format => :long)
  #end
end
