require 'test_helper'

# use ActionDispatch::IntegrationTest to access paths helpers
class WikiFilterTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::UrlHelper
  include SpeciesHelper
  include Aspects::PublicPaths

  def transform(text)
    SiteFormatStrategy.new(text).apply
  end

  # Screening - no need

  # Species

  test 'properly parse species by code {{Quails|cotnix}}' do
    assert_equal %Q("(sp_link). Quail":cotnix\n\n[cotnix]#{species_path(seed(:cotnix))}),
                 transform('{{Quail|cotnix}}')
  end

  test 'properly parse species by bare code {{cotnix}}' do
    assert_equal %Q("(sp_link). Coturnix coturnix":cotnix\n\n[cotnix]#{species_path(seed(:cotnix))}),
                 transform('{{cotnix}}')
  end

  test 'properly parse species by scientific name {{Quails|Coturnix coturnix}}' do
    assert_equal %Q("(sp_link). Quail":cotnix\n\n[cotnix]#{species_path(seed(:cotnix))}),
                 transform('{{Quail|Coturnix coturnix}}')
  end

  test 'properly parse species by bare scientific name {{Coturnix coturnix}}' do
    assert_equal %Q("(sp_link). Coturnix coturnix":cotnix\n\n[cotnix]#{species_path(seed(:cotnix))}),
                 transform('{{Coturnix coturnix}}')
  end

  test 'properly parse species name with undescore {{Quails|Coturnix_coturnix}}' do
    assert_equal %Q("(sp_link). Quail":cotnix\n\n[cotnix]#{species_path(seed(:cotnix))}),
                 transform('{{Quail|Coturnix coturnix}}')
  end

  test 'properly parse species in the string' do
    assert_equal %Q(Those were "(sp_link). quails":cotnix!\n\n[cotnix]#{species_path(seed(:cotnix))}),
                 transform('Those were {{quails|cotnix}}!')
  end

  test 'Add English name after species link' do
    assert_equal %Q("(sp_link). Перепел":cotnix (Common Quail)\n\n[cotnix]#{species_path(seed(:cotnix))}),
                 transform('{{Перепел|cotnix|en}}')
  end

  test 'Use English name if no word specified' do
    assert_equal %Q("(sp_link). Common Quail":cotnix\n\n[cotnix]#{species_path(seed(:cotnix))}),
                 transform('{{cotnix|en}}')
  end

  # Posts

  #  test 'properly parse post by code {{#see this|some-post}}' do
  #    blogpost = create(:post)
  #    assert_equal post_link('see this', blogpost),
  #                 transform('{{#see this|some-post}}')
  #  end

  # Allowed fallbacks

  test 'ignore unknown species code (name provided)' do
    assert_equal 'Emu', transform('{{Emu|dronov}}')
  end

  test 'show unknown species code (no name provided)' do
    assert_equal 'dronov', transform('{{dronov}}')
  end

  test 'properly show unknown scientific name (name provided)' do
    assert_equal unknown_species('Emu', 'Dromaius novaehollandiae'), transform('{{Emu|Dromaius novaehollandiae}}')
  end

  test 'properly show unknown scientific name (no name provided)' do
    assert_equal unknown_species(nil, 'Dromaius novaehollandiae'), transform('{{Dromaius novaehollandiae}}')
  end

  # Combined

  test 'properly parse two species' do
    result = transform('{{Great|parmaj}} and {{Blue Tits|parcae}}')
    text, links = result.split("\n\n")
    assert_equal %Q("(sp_link). Great":parmaj and "(sp_link). Blue Tits":parcae), text

    assert_equal ["[parcae]#{species_path(seed(:parcae))}", "[parmaj]#{species_path(seed(:parmaj))}"],
                 links.split("\n").sort
  end

  test 'properly parse pipe in the second code' do
    blogpost = create(:post)
    slug = blogpost.slug
    assert_equal %Q(""Test Post"":#{slug} has "(sp_link). Blue Tits":parcae\n\n[#{slug}]#{public_post_path(blogpost)}\n[parcae]#{species_path(seed(:parcae))}),
                 transform("{{##{slug}}} has {{Blue Tits|parcae}}")
  end

  # HTML entities

  test 'preserve HTML entities' do
    assert_equal %Q("(sp_link). Linotte m&eacute;lodieuse":acacan\n\n[acacan]#{species_path(seed(:acacan))}),
                 transform('{{Linotte m&eacute;lodieuse|acacan}}')
  end

  # Erroneous

  test 'do not parse species with post or link modifier {{#cotnix}}' do
    assert_not_equal species_link(seed(:cotnix), 'Coturnix coturnix'), transform('{{#cotnix}}')
    assert_not_equal species_link(seed(:cotnix), 'Coturnix coturnix'), transform('{{@cotnix}}')
  end

  test 'properly handle missed code' do
    assert_equal 'vid', transform('{{vid|}}')
  end

  #  test 'properly handle almost empty tags' do
  #    assert_equal '{{}}', transform('{{}}')
  #    #assert_equal '', transform('{{|}}')
  #    assert_equal '', transform('{{@}}')
  #    assert_equal '', transform('{{#}}')
  #    assert_equal '', transform('{{@|}}')
  #    assert_equal '', transform('{{#|}}')
  #  end

end
