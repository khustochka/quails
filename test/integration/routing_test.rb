require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  fixtures :all

  should 'route correctly' do
    assert_routing '/', {:controller => 'posts', :action => 'index'}
    assert_routing '/lifelist', {:controller => 'species', :action => 'lifelist'}
    assert_routing '/lifelist', {:controller => 'species', :action => 'lifelist'}
    assert_routing '/lifelist/2008', {:controller => 'species', :action => 'lifelist', :year => '2008'}
    assert_routing '/lifelist/2010/kiev', {:controller => 'species', :action => 'lifelist', :year => '2010', :locus => 'kiev'}
    assert_routing '/lifelist/kherson_obl', {:controller => 'species', :action => 'lifelist', :locus => 'kherson_obl'}
  end
end
