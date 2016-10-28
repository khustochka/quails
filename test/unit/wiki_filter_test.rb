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

  test 'properly parse species by code {{Wryneck|jyntor}}' do
    assert_equal %Q("(sp_link). Wryneck":jyntor\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{Wryneck|jyntor}}')
  end

  test 'properly parse species code capitalized' do
    assert_equal %Q("(sp_link). Wryneck":jyntor\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{Wryneck|Jyntor}}')
  end

  test 'properly parse species by bare code {{jyntor}}' do
    assert_equal %Q("(sp_link). Jynx torquilla":jyntor\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{jyntor}}')
  end

  test 'properly parse species by scientific name {{Wrynecks|Jynx torquilla}}' do
    assert_equal %Q("(sp_link). Wryneck":jyntor\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{Wryneck|Jynx torquilla}}')
  end

  test 'properly parse species by scientific name with underscore' do
    assert_equal %Q("(sp_link). Wryneck":jyntor\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{Wryneck|Jynx_torquilla}}')
  end

  test 'properly parse species by scientific name when species has no code' do
    assert_equal %Q("(sp_link). Heuglin's Gull":Larus_heuglini\n\n[Larus_heuglini]#{species_path(species(:larheu))}),
                 transform("{{Heuglin's Gull|Larus heuglini}}")
  end

  test 'properly parse species by legacy scientific name' do
    assert_equal %Q("(sp_link). Stonechat":saxola\n\n[saxola]#{species_path(species(:saxola))}),
                 transform("{{Stonechat|Saxicola torquata}}")
  end

  test 'properly parse species by bare scientific name {{Jynx torquilla}}' do
    assert_equal %Q("(sp_link). Jynx torquilla":jyntor\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{Jynx torquilla}}')
  end

  test 'properly parse species name with undescore {{Wryneck|Jynx_torquilla}}' do
    assert_equal %Q("(sp_link). Wryneck":jyntor\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{Wryneck|Jynx torquilla}}')
  end

  test 'properly parse species in the string' do
    assert_equal %Q(Those were "(sp_link). Wrynecks":jyntor!\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('Those were {{Wrynecks|jyntor}}!')
  end

  test 'Add English name after species link' do
    assert_equal %Q("(sp_link). Вертишейка":jyntor (Wryneck)\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{Вертишейка|jyntor|en}}')
  end

  test 'Use English name if no word specified' do
    assert_equal %Q("(sp_link). Wryneck":jyntor\n\n[jyntor]#{species_path(species(:jyntor))}),
                 transform('{{jyntor|en}}')
  end

  # Posts

   test 'properly parse post by code {{#see this|some-post}}' do
     blogpost = Post.create!(slug: "some-post", title: "Some post", topic: "OBSR", status: "OPEN", text: "Aaaa")
     assert_equal "\"see this\":some-post\n\n[some-post]#{public_post_path(blogpost)}",
                  transform('{{#see this|some-post}}')
   end

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
    result = transform('{{Sparrows|pasdom}} and {{Barn Swallows|hirrus}}')
    text, links = result.split("\n\n")
    assert_equal %Q("(sp_link). Sparrows":pasdom and "(sp_link). Barn Swallows":hirrus), text

    assert_equal ["[hirrus]#{species_path(species(:hirrus))}", "[pasdom]#{species_path(species(:pasdom))}"],
                 links.split("\n").sort
  end

  test 'properly parse pipe in the second code' do
    blogpost = create(:post)
    slug = blogpost.slug
    assert_equal %Q(""Test Post"":#{slug} has "(sp_link). Wrynecks":jyntor\n\n[#{slug}]#{public_post_path(blogpost)}\n[jyntor]#{species_path(species(:jyntor))}),
                 transform("{{##{slug}}} has {{Wrynecks|jyntor}}")
  end

  # HTML entities

  test 'preserve HTML entities' do
    assert_equal %Q("(sp_link). Linotte m&eacute;lodieuse":bomgar\n\n[bomgar]#{species_path(species(:bomgar))}),
                 transform('{{Linotte m&eacute;lodieuse|bomgar}}')
  end

  # Erroneous

  test 'do not parse species with post or link modifier {{#jyntor}}' do
    assert_not_equal species_link(species(:jyntor), 'Jynx torquilla'), transform('{{#jyntor}}')
    assert_not_equal species_link(species(:jyntor), 'Jynx torquilla'), transform('{{@jyntor}}')
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
