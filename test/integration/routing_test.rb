require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  fixtures :all

  should 'route index correctly' do
    assert_routing '/', {:controller => 'posts', :action => 'index'}
  end

  should 'route posts correctly' do
    assert_routing '/2008', {:controller => 'posts', :action => 'year', :year => '2008'}
    assert_routing '/2010/04', {:controller => 'posts', :action => 'index', :year => '2010', :month => '04'}
    assert_routing '/2009/07/some-post', {:controller => 'posts', :action => 'show',
                                          :year => '2010', :month => '04', id => 'some-post'}
  end

  should 'route species correctly' do
    assert_routing '/species/Aquilla_pomarina', {:controller => 'species', :action => 'show', :id => 'Aquilla_pomarina'}
  end

  should 'route lifelist correctly' do
    assert_routing '/lifelist', {:controller => 'species', :action => 'lifelist'}
    assert_routing '/lifelist', {:controller => 'species', :action => 'lifelist'}
    assert_routing '/lifelist/2008', {:controller => 'species', :action => 'lifelist', :year => '2008'}
    assert_routing '/lifelist/2010/kiev', {:controller => 'species', :action => 'lifelist', :year => '2010', :locus => 'kiev'}
    assert_routing '/lifelist/kherson_obl', {:controller => 'species', :action => 'lifelist', :locus => 'kherson_obl'}
  end
end