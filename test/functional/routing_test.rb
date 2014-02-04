require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  fixtures :all

  test 'route index correctly' do
    assert_routing '/', {controller: 'blog', action: 'home'}
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

  test 'route species index and gallery' do
    assert_routing '/species', {controller: 'species', action: 'gallery'}
    assert_routing '/species/admin', {controller: 'species', action: 'index'}
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
    assert_routing '/photos/lesser_spotted_eagle',
                   {controller: 'images', action: 'show', id: 'lesser_spotted_eagle'}
  end

  test 'route to photos of several species' do
    assert_routing '/photos/multiple_species',
                   {controller: 'images', action: 'multiple_species'}
  end

  test 'photos paging' do
    assert_routing '/photos/page/2',
                   {controller: 'images', action: 'index', page: '2'}
  end

  test 'route feeds and sitemap correctly' do
    assert_routing '/blog.xml', {controller: 'feeds', action: 'blog', format: 'xml'}
    assert_routing '/photos.xml', {controller: 'feeds', action: 'photos', format: 'xml'}
    assert_routing '/sitemap.xml', {controller: 'feeds', action: 'sitemap', format: 'xml'}
  end

  test 'route countries correctly' do
    assert_routing '/ukraine', {controller: 'countries', action: 'gallery', country: 'ukraine'}
    assert_routing '/ukraine/checklist', {controller: 'checklist', action: 'show', country: 'ukraine'}
  end

  # Localized routes
  test 'English root routing' do
    assert_routing '/en', {controller: 'images', action: 'index', locale: 'en'}
  end

  test 'English Birds of Ukraine, USA, checklist routing' do
    assert_routing '/en/ukraine', {controller: 'countries', action: 'gallery', locale: 'en', country: 'ukraine'}
    assert_routing '/en/ukraine/checklist', {controller: 'checklist', action: 'show', locale: 'en', country: 'ukraine'}
    assert_routing '/en/usa', {controller: 'countries', action: 'gallery', locale: 'en', country: 'usa'}
  end

  test 'English species gallery routing' do
    assert_routing '/en/species', {controller: 'species', action: 'gallery', locale: 'en'}
  end

  test 'English map routing' do
    assert_routing '/en/map', {controller: 'maps', action: 'show', locale: 'en'}
  end

  test 'English species routing' do
    assert_routing '/en/species/Passer_domesticus', {controller: 'species', action: 'show', locale: 'en', id: 'Passer_domesticus'}
  end

  test 'English photo routing' do
    assert_routing '/en/photos/sparrow12345', {controller: 'images', action: 'show', locale: 'en', id: 'sparrow12345'}
  end

  test 'English lifelists routing' do
    assert_routing '/en/my/lists', {controller: 'lists', action: 'index', locale: 'en'}
    assert_routing '/en/my/lists/2009', {controller: 'lists', action: 'basic', locale: 'en', year: '2009'}
    assert_routing '/en/my/lists/usa', {controller: 'lists', action: 'basic', locale: 'en', locus: 'usa'}
    assert_routing '/en/my/lists/usa/2011', {controller: 'lists', action: 'basic', locale: 'en', locus: 'usa', year: '2011'}
  end

  test 'English my stats routing' do
    assert_routing '/en/my', {controller: 'my_stats', action: 'index', locale: 'en'}
  end



end
