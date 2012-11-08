# -*- encoding: utf-8 -*-

require 'test_helper'
require 'capybara_helper'

class I18NTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Use standalone month names in Russian' do
    create(:post, face_date: '2011-01-09')
    visit month_path(year: '2011', month: '01', hl: :ru)
    assert_equal 'Январь 2011', find('h1').text
  end

  test 'Use standalone month names in English' do
    create(:post, face_date: '2011-01-09')
    visit month_path(year: '2011', month: '01', hl: :en)
    assert_equal 'January 2011', find('h1').text
  end

  test 'Properly parse pubdate in English' do
    blogpost = create(:post, face_date: '2011-01-09')
    visit show_post_path(blogpost.to_url_params.merge(hl: :en))
    assert_match /^January 9, 2011/, find('time').text
  end

  test 'Properly parse pubdate in Russian' do
    blogpost = create(:post, face_date: '2011-01-09')
    visit show_post_path(blogpost.to_url_params.merge(hl: :ru))
    assert_match /^9 января 2011/, find('time').text
  end

end
