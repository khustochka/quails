# -*- encoding: utf-8 -*-

require 'test_helper'
require 'capybara_helper'

class UIPostsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Use standalone month names in Russian' do
    create(:post, face_date: '2011-01-09')
    visit month_path(year: '2011', month: '01', hl: :ru)
    find('h1').text.should == 'Январь 2011'
  end

  test 'Use standalone month names in English' do
    create(:post, face_date: '2011-01-09')
    visit month_path(year: '2011', month: '01', hl: :en)
    find('h1').text.should == 'January 2011'
  end

  test 'Properly parse pubdate in English' do
    blogpost = create(:post, face_date: '2011-01-09')
    visit show_post_path(blogpost.to_url_params.merge(hl: :en))
    find('time').text.should match(/^January 9, 2011/)
  end

  test 'Properly parse pubdate in Russian' do
    blogpost = create(:post, face_date: '2011-01-09')
    visit show_post_path(blogpost.to_url_params.merge(hl: :ru))
    find('time').text.should match(/^9 января 2011/)
  end

end
