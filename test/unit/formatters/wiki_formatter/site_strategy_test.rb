# frozen_string_literal: true

require "test_helper"

# use ActionDispatch::IntegrationTest to access paths helpers
class WikiFormatter::SiteStrategyTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::UrlHelper
  include SpeciesHelper
  include PublicPaths

  def transform_textile(text)
    WikiFormatter.new(text, converter: Converter::Textile).for_site
  end

  def transform_kramdown(text)
    WikiFormatter.new(text, converter: Converter::Kramdown).for_site
  end

  # TEXTILE

  # Species

  test "(textile) properly parse species by code {{Wryneck|jyntor}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>",
      transform_textile("{{Wryneck|jyntor}}")
  end

  test "(textile) properly parse species by legacy code {{Stonechat|saxtor}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Saxicola_rubicola\">Stonechat</a></p>",
      transform_textile("{{Stonechat|saxtor}}")
  end

  test "(textile) properly parse species by bare code {{jyntor}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Jynx torquilla</a></p>",
      transform_textile("{{jyntor}}")
  end

  test "(textile) properly parse species by scientific name {{Wrynecks|Jynx torquilla}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>",
      transform_textile("{{Wryneck|Jynx torquilla}}")
  end

  test "(textile) properly parse species by scientific name when species has no code" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Larus_heuglini\">Heuglin&#8217;s Gull</a></p>",
      transform_textile("{{Heuglin's Gull|Larus heuglini}}")
  end

  test "(textile) properly parse species by legacy scientific name" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Saxicola_rubicola\">Stonechat</a></p>",
      transform_textile("{{Stonechat|Saxicola torquata}}")
  end

  test "(textile) properly parse species by bare scientific name {{Jynx torquilla}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Jynx torquilla</a></p>",
      transform_textile("{{Jynx torquilla}}")
  end

  test "(textile) properly parse species name with undescore {{Wryneck|Jynx_torquilla}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>",
      transform_textile("{{Wryneck|Jynx torquilla}}")
  end

  test "(textile) properly parse species in the string" do
    assert_equal "<p>Those were <a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wrynecks</a>!</p>",
      transform_textile("Those were {{Wrynecks|jyntor}}!")
  end

  test "(textile) Add English name after species link" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Вертишейка</a> (Wryneck)</p>",
      transform_textile("{{Вертишейка|jyntor|en}}")
  end

  test "(textile) Use English name if no word specified" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>",
      transform_textile("{{jyntor|en}}")
  end

  # Allowed fallbacks

  test "(textile) ignore unknown species code (name provided)" do
    assert_equal "<p>Emu</p>", transform_textile("{{Emu|dronov}}")
  end

  test "(textile) show unknown species code (no name provided)" do
    assert_equal "<p>dronov</p>", transform_textile("{{dronov}}")
  end

  test "(textile) properly show unknown scientific name (name provided)" do
    assert_equal "<p><span title=\"Dromaius novaehollandiae\">Emu</span></p>",
      transform_textile("{{Emu|Dromaius novaehollandiae}}")
  end

  test "(textile) properly show unknown scientific name (no name provided)" do
    assert_equal "<p><i class=\"sci_name\">Dromaius novaehollandiae</i></p>",
      transform_textile("{{Dromaius novaehollandiae}}")
  end

  # Combined

  test "(textile) properly parse two species" do
    text = transform_textile("{{Sparrows|pasdom}} and {{Barn Swallows|hirrus}}")
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Passer_domesticus\">Sparrows</a> and <a class=\"sp_link\" href=\"/species/Hirundo_rustica\">Barn Swallows</a></p>", text
  end

  # Erroneous

  test "(textile) do not parse species with post or link modifier {{#jyntor}}" do
    assert_not transform_kramdown("{{#jyntor}}").include?(species_link(species(:jyntor), "Jynx torquilla"))
    assert_not transform_kramdown("{{@jyntor}}").include?(species_link(species(:jyntor), "Jynx torquilla"))
  end

  test "(textile) properly handle missed code" do
    assert_equal "<p>vid</p>", transform_textile("{{vid|}}")
  end

  # Posts

  test "(textile) properly parse post by code {{#see this|some-post}}" do
    blogpost = create(:post, slug: "some-post")

    assert_equal "<p><a href=\"#{public_post_path(blogpost)}\">see this</a></p>",
      transform_textile("{{#see this|some-post}}")
  end

  test "(textile) properly parse pipe in the second code" do
    blogpost = create(:post)
    slug = blogpost.slug

    assert_equal "<p><a href=\"#{public_post_path(blogpost)}\">«Test Post»</a> has <a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wrynecks</a></p>",
      transform_textile("{{##{slug}}} has {{Wrynecks|jyntor}}")
  end

  # Images TODO

  # Videos TODO


  # HTML entities

  test "(textile) preserve HTML entities" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Bombycilla_garrulus\">Linotte m&eacute;lodieuse</a></p>",
      transform_textile("{{Linotte m&eacute;lodieuse|bomgar}}")
  end

  # KRAMDOWN

  # Species

  test "(kramdown) properly parse species by code {{Wryneck|jyntor}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>\n",
      transform_kramdown("{{Wryneck|jyntor}}")
  end

  test "(kramdown) properly parse species by legacy code {{Stonechat|saxtor}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Saxicola_rubicola\">Stonechat</a></p>\n",
      transform_kramdown("{{Stonechat|saxtor}}")
  end

  test "(kramdown) properly parse species by bare code {{jyntor}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Jynx torquilla</a></p>\n",
      transform_kramdown("{{jyntor}}")
  end

  test "(kramdown) properly parse species by scientific name {{Wrynecks|Jynx torquilla}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>\n",
      transform_kramdown("{{Wryneck|Jynx torquilla}}")
  end

  test "(kramdown) properly parse species by scientific name when species has no code" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Larus_heuglini\">Heuglin’s Gull</a></p>\n",
      transform_kramdown("{{Heuglin's Gull|Larus heuglini}}")
  end

  test "(kramdown) properly parse species by legacy scientific name" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Saxicola_rubicola\">Stonechat</a></p>\n",
      transform_kramdown("{{Stonechat|Saxicola torquata}}")
  end

  test "(kramdown) properly parse species by bare scientific name {{Jynx torquilla}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Jynx torquilla</a></p>\n",
      transform_kramdown("{{Jynx torquilla}}")
  end

  test "(kramdown) properly parse species name with undescore {{Wryneck|Jynx_torquilla}}" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>\n",
      transform_kramdown("{{Wryneck|Jynx torquilla}}")
  end

  test "(kramdown) properly parse species in the string" do
    assert_equal "<p>Those were <a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wrynecks</a>!</p>\n",
      transform_kramdown("Those were {{Wrynecks|jyntor}}!")
  end

  test "(kramdown) Add English name after species link" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Вертишейка</a> (Wryneck)</p>\n",
      transform_kramdown("{{Вертишейка|jyntor|en}}")
  end

  test "(kramdown) Use English name if no word specified" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wryneck</a></p>\n",
      transform_kramdown("{{jyntor|en}}")
  end

  # Allowed fallbacks

  test "(kramdown) ignore unknown species code (name provided)" do
    assert_equal "<p>Emu</p>\n", transform_kramdown("{{Emu|dronov}}")
  end

  test "(kramdown) show unknown species code (no name provided)" do
    assert_equal "<p>dronov</p>\n", transform_kramdown("{{dronov}}")
  end

  test "(kramdown) properly show unknown scientific name (name provided)" do
    assert_equal "<p><span title=\"Dromaius novaehollandiae\">Emu</span></p>\n",
      transform_kramdown("{{Emu|Dromaius novaehollandiae}}")
  end

  test "(kramdown) properly show unknown scientific name (no name provided)" do
    assert_equal "<p><i class=\"sci_name\">Dromaius novaehollandiae</i></p>\n",
      transform_kramdown("{{Dromaius novaehollandiae}}")
  end

  # Combined

  test "(kramdown) properly parse two species" do
    text = transform_kramdown("{{Sparrows|pasdom}} and {{Barn Swallows|hirrus}}")
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Passer_domesticus\">Sparrows</a> and <a class=\"sp_link\" href=\"/species/Hirundo_rustica\">Barn Swallows</a></p>\n", text
  end

  # Erroneous

  test "(kramdown) do not parse species with post or link modifier {{#jyntor}}" do
    assert_not transform_kramdown("{{#jyntor}}").include?(species_link(species(:jyntor), "Jynx torquilla"))
    assert_not transform_kramdown("{{@jyntor}}").include?(species_link(species(:jyntor), "Jynx torquilla"))
  end

  test "(kramdown) properly handle missed code" do
    assert_equal "<p>vid</p>\n", transform_kramdown("{{vid|}}")
  end

  # Posts

  test "(kramdown) properly parse post by code {{#see this|some-post}}" do
    blogpost = create(:post, slug: "some-post")

    assert_equal "<p><a href=\"#{public_post_path(blogpost)}\">see this</a></p>\n",
      transform_kramdown("{{#see this|some-post}}")
  end

  test "(kramdown) properly parse pipe in the second code" do
    blogpost = create(:post)
    slug = blogpost.slug

    assert_equal "<p><a href=\"#{public_post_path(blogpost)}\">“Test Post”</a> has <a class=\"sp_link\" href=\"/species/Jynx_torquilla\">Wrynecks</a></p>\n",
      transform_kramdown("{{##{slug}}} has {{Wrynecks|jyntor}}")
  end

  # Images TODO


  # Videos TODO


  # HTML entities

  test "(kramdown) preserve HTML entities" do
    assert_equal "<p><a class=\"sp_link\" href=\"/species/Bombycilla_garrulus\">Linotte mélodieuse</a></p>\n",
      transform_kramdown("{{Linotte m&eacute;lodieuse|bomgar}}")
  end

  #  test 'properly handle almost empty tags' do
  #    assert_equal '{{}}', transform_textile('{{}}')
  #    #assert_equal '', transform_textile('{{|}}')
  #    assert_equal '', transform_textile('{{@}}')
  #    assert_equal '', transform_textile('{{#}}')
  #    assert_equal '', transform_textile('{{@|}}')
  #    assert_equal '', transform_textile('{{#|}}')
  #  end
end
