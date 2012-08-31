require 'test_helper'
require 'wiki_filter'

# use ActionDispatch::IntegrationTest to access paths helpers
class WikiFilterTest < ActionDispatch::IntegrationTest

  include WikiFilter
  include ActionView::Helpers::UrlHelper
  include SpeciesHelper
  include PostsHelper

  # Screening - no need

  #test 'do not parse screened square brackets as tag' do
  #  assert_equal '[Quail|cotnix]', transform('\[Quail|cotnix\]')
  #end

  # Species

  test 'properly parse species by code [Quails|cotnix]' do
    assert_equal species_link(seed(:cotnix), 'Quail'),
                 transform('[Quail|cotnix]')
  end

  test 'properly parse species by bare code [cotnix]' do
    assert_equal species_link(seed(:cotnix), 'Coturnix coturnix'),
                 transform('[cotnix]')
  end

  test 'properly parse species by scientific name [Quails|Coturnix coturnix]' do
    assert_equal species_link(seed(:cotnix), 'Quail'),
                 transform('[Quail|Coturnix coturnix]')
  end

  test 'properly parse species by bare scientific name [Coturnix coturnix]' do
    assert_equal species_link(seed(:cotnix), 'Coturnix coturnix'),
                 transform('[Coturnix coturnix]')
  end

  test 'properly parse species name with undescore [Quails|Coturnix_coturnix]' do
    assert_equal species_link(seed(:cotnix), 'Quail'),
                 transform('[Quail|Coturnix coturnix]')
  end

  test 'properly parse species in the string' do
    assert_equal "Those were #{species_link(seed(:cotnix), 'quails')}!",
                 transform('Those were [quails|cotnix]!')
  end

  # Posts

  #  test 'properly parse post by code [#see this|some-post]' do
  #    blogpost = create(:post)
  #    assert_equal post_link('see this', blogpost),
  #                 transform('[#see this|some-post]')
  #  end

  # Links

  test 'properly parse links with text [@see this|http://google.com]' do
    assert_equal link_to('see this', 'http://google.com'),
                 transform('[@see this|http://google.com]')
  end

  test 'properly parse links without text [@http://google.com]' do
    assert_equal link_to('http://google.com', 'http://google.com'),
                 transform('[@http://google.com]')
  end

  # Allowed fallbacks

  test 'ignore unknown species code (name provided)' do
    assert_equal 'Emu', transform('[Emu|dronov]')
  end

  test 'show unknown species code (no name provided)' do
    assert_equal 'dronov', transform('[dronov]')
  end

  test 'properly show unknown scientific name (name provided)' do
    assert_equal unknown_species('Emu', 'Dromaius novaehollandiae'), transform('[Emu|Dromaius novaehollandiae]')
  end

  test 'properly show unknown scientific name (no name provided)' do
    assert_equal unknown_species(nil, 'Dromaius novaehollandiae'), transform('[Dromaius novaehollandiae]')
  end

  # Combined

  test 'properly parse two species' do
    assert_equal "#{species_link(seed(:parmaj), 'Great')} and #{species_link(seed(:parcae), 'Blue Tits')}",
                 transform('[Great|parmaj] and [Blue Tits|parcae]')
  end

  test 'properly parse pipe in the second code' do
    assert_equal "#{link_to(nil, 'http://birdwatch.by')} has #{species_link(seed(:parcae), 'Blue Tits')}",
                 transform('[@http://birdwatch.by] has [Blue Tits|parcae]')
  end

  # HTML entities

  test 'preserve HTML entities' do
    assert_equal species_link(seed(:acacan), 'Linotte m&eacute;lodieuse'.html_safe),
                 transform('[Linotte m&eacute;lodieuse|acacan]')
  end

  # Nested - not working for now

  #test 'properly parse nested square brackets' do
  #  assert_equal species_link(seed(:parmaj), '[some bird]'),
  #               transform('[\[some bird\]|parmaj]')
  #end

  # Erroneous

  test 'do not parse species with post or link modifier [#cotnix]' do
    assert_not_equal species_link(seed(:cotnix), 'Coturnix coturnix'), transform('[#cotnix]')
    assert_not_equal species_link(seed(:cotnix), 'Coturnix coturnix'), transform('[@cotnix]')
  end

  #  test 'properly parse non closed tag' do
  #    assert_equal "[Great|parmaj or  #{species_link(seed(:parcae), 'Blue Tit')}",
  #                 transform('[Great|parmaj or [Blue Tit|parcae]')
  #  end

  #  test 'properly handle almost empty tags' do
  #    assert_equal '[]', transform('[]')
  #    #assert_equal '', transform('[|]')
  #    assert_equal '', transform('[@]')
  #    assert_equal '', transform('[#]')
  #    assert_equal '', transform('[@|]')
  #    assert_equal '', transform('[#|]')
  #  end

end
