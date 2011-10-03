require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  fixtures :all

  test 'route index correctly' do
    assert_routing '/', {:controller => 'posts', :action => 'index'}
  end

  test 'route posts correctly' do
    assert_routing '/2008', {:controller => 'posts', :action => 'year', :year => '2008'}
    assert_routing '/2010/04', {:controller => 'posts', :action => 'month', :year => '2010', :month => '04'}
    assert_routing '/2009/07/some-post', {:controller => 'posts', :action => 'show',
                                          :year => '2009', :month => '07', :id => 'some-post'}
  end

  test 'route species correctly' do
    assert_routing '/species/Aquilla_pomarina', {:controller => 'species', :action => 'show', :id => 'Aquilla_pomarina'}
    assert_routing '/species/Aquilla_pomarina/edit', {:controller => 'species', :action => 'edit', :id => 'Aquilla_pomarina'}
  end

  test 'route lifelist correctly' do
    assert_routing '/lifelist', {:controller => 'lifelist', :action => 'default'}
    assert_routing '/lifelist/by_count', {:controller => 'lifelist', :action => 'by_count'}
    assert_routing '/lifelist/by_taxonomy', {:controller => 'lifelist', :action => 'by_taxonomy'}
    assert_routing '/lifelist/2008', {:controller => 'lifelist', :action => 'default', :year => '2008'}
    assert_routing '/lifelist/2008/by_count', {:controller => 'lifelist', :action => 'by_count', :year => '2008'}
    assert_routing '/lifelist/2008/by_taxonomy', {:controller => 'lifelist', :action => 'by_taxonomy', :year => '2008'}
    assert_routing '/lifelist/2010/kiev', {:controller => 'lifelist', :action => 'default', :year => '2010', :locus => 'kiev'}
    assert_routing '/lifelist/kherson_obl', {:controller => 'lifelist', :action => 'default', :locus => 'kherson_obl'}
    assert_routing '/lifelist/kherson_obl/by_count', {:controller => 'lifelist', :action => 'by_count', :locus => 'kherson_obl'}
    assert_routing '/lifelist/2010/kiev/by_count', {:controller => 'lifelist', :action => 'by_count', :year => '2010', :locus => 'kiev'}
  end

  test 'route images correctly' do
    assert_routing '/species/Aquilla_pomarina/lesser_spotted_eagle',
                   {:controller => 'images', :action => 'show', :species => 'Aquilla_pomarina', :id => 'lesser_spotted_eagle'}
  end
end
