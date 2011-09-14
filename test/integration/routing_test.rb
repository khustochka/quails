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
    #assert_routing '/lifelist/2008', {:controller => 'lifelist', :action => 'lifelist', :year => '2008'}
    #assert_routing '/lifelist/2010/kiev', {:controller => 'lifelist', :action => 'lifelist', :year => '2010', :locus => 'kiev'}
    #assert_routing '/lifelist/kherson_obl', {:controller => 'lifelist', :action => 'lifelist', :locus => 'kherson_obl'}
  end

  test 'route images correctly' do
    assert_routing '/species/Aquilla_pomarina/lesser_spotted_eagle',
                   {:controller => 'images', :action => 'show', :species => 'Aquilla_pomarina', :id => 'lesser_spotted_eagle'}
  end
end