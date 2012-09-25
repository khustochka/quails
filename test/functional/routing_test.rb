require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  fixtures :all

  test 'route index correctly' do
    assert_routing '/', {controller: 'blog', action: 'front_page'}
  end

  test 'route posts correctly' do
    assert_routing '/2008', {controller: 'blog', action: 'year', year: '2008'}
    assert_routing '/2010/04', {controller: 'blog', action: 'month', year: '2010', month: '04'}
    assert_routing '/2009/07/some-post', {controller: 'posts', action: 'show',
                                          year: '2009', month: '07', id: 'some-post'}
  end

  test 'route species correctly' do
    assert_routing '/species/Aquilla_pomarina', {controller: 'species', action: 'show', id: 'Aquilla_pomarina'}
    assert_routing '/species/Aquilla_pomarina/edit', {controller: 'species', action: 'edit', id: 'Aquilla_pomarina'}
  end

  test 'route `/my` correctly' do
    assert_routing '/my', {controller: 'my_stats', action: 'index'}
  end

  test 'route lists correctly' do
    assert_routing '/my/lists', {controller: "lists", action: "index"}
  end

  test 'route lifelist correctly' do
    assert_routing '/my/lists/life', {controller: "lists", action: "basic"}
    assert_routing '/my/lists/advanced', {controller: "lists", action: 'advanced'}
    assert_routing '/my/lists/life/by_taxonomy', {controller: "lists", action: "basic", sort: 'by_taxonomy'}
    assert_routing '/my/lists/2008', {controller: "lists", action: "basic", year: '2008'}
    assert_routing '/my/lists/2008/by_taxonomy', {controller: "lists", action: "basic", sort: 'by_taxonomy', year: '2008'}
    assert_routing '/my/lists/kiev/2010', {controller: "lists", action: "basic", year: '2010', locus: 'kiev'}
    assert_routing '/my/lists/kherson_obl', {controller: "lists", action: "basic", locus: 'kherson_obl'}
    assert_routing '/my/lists/kherson_obl/by_taxonomy', {controller: "lists", action: "basic", sort: 'by_taxonomy', locus: 'kherson_obl'}
    assert_routing '/my/lists/kiev/2010/by_taxonomy', {controller: "lists", action: "basic", sort: 'by_taxonomy', year: '2010', locus: 'kiev'}
    # have 'by_' inside locus
    assert_routing '/my/lists/druzhby_obl/by_taxonomy', {controller: "lists", action: "basic", sort: 'by_taxonomy', locus: 'druzhby_obl'}
  end

  test 'route images correctly' do
    assert_routing '/species/Aquilla_pomarina/lesser_spotted_eagle',
                   {controller: 'images', action: 'show', species: 'Aquilla_pomarina', id: 'lesser_spotted_eagle'}
  end

  test 'route observations correctly' do
    assert_routing '/observations/11876', {controller: 'observations', action: 'show', id: "11876"}
    assert_routing '/observations/new', {controller: 'observations', action: 'new'}
    assert_routing '/observations/11876/edit', {controller: 'observations', action: 'edit', id: "11876"}
    assert_routing '/observations/add', {controller: 'observations', action: 'add'}
    assert_routing '/observations/bulk', {controller: 'observations', action: 'bulk'}
  end

  test 'route feeds and sitemap correctly' do
    assert_routing '/blog.xml', {controller: 'feeds', action: 'blog', format: 'xml'}
    assert_routing '/photos.xml', {controller: 'feeds', action: 'photos', format: 'xml'}
    assert_generates '/sitemap', {controller: 'feeds', action: 'sitemap', format: 'xml'}
    assert_recognizes({controller: 'feeds', action: 'sitemap', format: 'xml'}, '/sitemap.xml')
    assert_recognizes({controller: 'feeds', action: 'sitemap', format: 'xml'}, '/sitemap')
  end
end
