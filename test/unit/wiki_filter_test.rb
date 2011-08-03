require 'test_helper'
require 'wiki_filter'

# use ActionDispatch::IntegrationTest to access paths helpers
class WikiFilterTest < ActionDispatch::IntegrationTest

  include WikiFilter
  include ActionView::Helpers::UrlHelper
  include SpeciesHelper
  include PostsHelper

  # Screening

  should 'not parse screened square brackets as tag' do
    assert_equal '[Quail|cotnix]', transform('\[Quail|cotnix\]')
  end

  # Species

  should 'properly parse species by code [Quails|cotnix]' do
    assert_equal species_link(Species.find_by_code('cotnix'), 'Quail'),
                 transform('[Quail|cotnix]')
  end

  should 'properly parse species by bare code [cotnix]' do
    assert_equal species_link(Species.find_by_code('cotnix'), 'Common Quail'),
                 transform('[cotnix]')
  end

  should 'properly parse species by scientific name [Quails|Coturnix coturnix]' do
    assert_equal species_link(Species.find_by_code('cotnix'), 'Quail'),
                 transform('[Quail|Coturnix coturnix]')
  end

  should 'properly parse species by bare scientific name [Coturnix coturnix]' do
    assert_equal species_link(Species.find_by_code('cotnix'), 'Coturnix coturnix'),
                 transform('[Coturnix coturnix]')
  end

  should 'properly parse species name with undescore [Quails|Coturnix_coturnix]' do
    assert_equal species_link(Species.find_by_code('cotnix'), 'Quail'),
                 transform('[Quail|Coturnix coturnix]')
  end

  should 'properly parse species in the string' do
    assert_equal "Those were #{species_link(Species.find_by_code('cotnix'), 'quails')}!",
                 transform('Those were [quails|cotnix]!')
  end

  # Posts

#  should 'properly parse post by code [#see this|some-post]' do
#    blogpost = Factory.create(:post)
#    assert_equal post_link('see this', blogpost),
#                 transform('[#see this|some-post]')
#  end

  # Links

  should 'properly parse links with text [@see this|http://google.com]' do
    assert_equal link_to('see this', 'http://google.com'),
                 transform('[@see this|http://google.com]')
  end

  should 'properly parse links without text [@http://google.com]' do
    assert_equal link_to('http://google.com', 'http://google.com'),
                 transform('[@http://google.com]')
  end

  # Allowed fallbacks

  should 'properly parse not existing species code' do
    assert_equal 'Emu', transform('[Emu|dronov]')
  end

  should 'properly parse not existing scientific name' do
    assert_equal 'Emu', transform('[Emu|Dromaius novaehollandiae]')
  end



  # Combined

  should 'properly parse two species' do
    assert_equal "#{species_link(Species.find_by_code('parmaj'), 'Great')} and #{species_link(Species.find_by_code('parcae'), 'Blue Tits')}",
                 transform('[Great|parmaj] and [Blue Tits|parcae]')
  end

  # Nested

  should 'properly parse nested square brackets' do
    assert_equal species_link(Species.find_by_code('parmaj'), '[some bird]'),
                 transform('[[some bird]|parmaj]')
  end

  # Erroneous

#  should 'properly parse non closed tag' do
#    assert_equal "[Great|parmaj or  #{species_link(Species.find_by_code('parcae'), 'Blue Tit')}",
#                 transform('[Great|parmaj or [Blue Tit|parcae]')
#  end

#  should 'properly handle almost empty tags' do
#    assert_equal '[]', transform('[]')
#    #assert_equal '', transform('[|]')
#    assert_equal '', transform('[@]')
#    assert_equal '', transform('[#]')
#    assert_equal '', transform('[@|]')
#    assert_equal '', transform('[#|]')
#  end

end