require 'test_helper'
require 'rails/performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionDispatch::PerformanceTest

  def setup

  end

  def test_homepage
    get '/'
  end

  def test_sitemap
    get '/sitemap.xml'
  end

  def test_lifelist
    get '/my/lists/advanced'
  end

  #def test_more_than_year
  #  login_as_admin
  #  get '/research/more_than_year'
  #end
end
