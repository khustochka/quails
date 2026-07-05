# frozen_string_literal: true

require "test_helper"

# use ActionDispatch::IntegrationTest to access paths helpers
class WikiFilterTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::UrlHelper
  include SpeciesHelper
  include PublicPaths

  def transform(text)
    FormatStrategy::Site.new(text).apply
  end

  # Screening - no need

  # Species

  test "properly parse species by code {{Wryneck|jyntor}}" do
    assert_equal '<a class="sp_link" href="/species/Jynx_torquilla">Wryneck</a>',
      transform("{{Wryneck|jyntor}}")
  end

  test "properly parse species by legacy code {{Stonechat|saxtor}}" do
    assert_equal '<a class="sp_link" href="/species/Saxicola_rubicola">Stonechat</a>',
      transform("{{Stonechat|saxtor}}")
  end

  test "properly parse species by bare code {{jyntor}}" do
    assert_equal '<a class="sp_link" href="/species/Jynx_torquilla">Jynx torquilla</a>',
      transform("{{jyntor}}")
  end

  test "properly parse species by scientific name {{Wrynecks|Jynx torquilla}}" do
    assert_equal '<a class="sp_link" href="/species/Jynx_torquilla">Wryneck</a>',
      transform("{{Wryneck|Jynx torquilla}}")
  end

  test "properly parse species by scientific name when species has no code" do
    assert_equal "<a class=\"sp_link\" href=\"/species/Larus_heuglini\">Heuglin's Gull</a>",
      transform("{{Heuglin's Gull|Larus heuglini}}")
  end

  test "properly parse species by legacy scientific name" do
    assert_equal "<a class=\"sp_link\" href=\"/species/Saxicola_rubicola\">Stonechat</a>",
      transform("{{Stonechat|Saxicola torquata}}")
  end

  test "properly parse species by bare scientific name {{Jynx torquilla}}" do
    assert_equal '<a class="sp_link" href="/species/Jynx_torquilla">Jynx torquilla</a>',
      transform("{{Jynx torquilla}}")
  end

  test "properly parse species name with undescore {{Wryneck|Jynx_torquilla}}" do
    assert_equal '<a class="sp_link" href="/species/Jynx_torquilla">Wryneck</a>',
      transform("{{Wryneck|Jynx torquilla}}")
  end

  test "properly parse species in the string" do
    assert_equal 'Those were <a class="sp_link" href="/species/Jynx_torquilla">Wrynecks</a>!',
      transform("Those were {{Wrynecks|jyntor}}!")
  end

  test "Add English name after species link" do
    assert_equal '<a class="sp_link" href="/species/Jynx_torquilla">Вертишейка</a> (Wryneck)',
      transform("{{Вертишейка|jyntor|en}}")
  end

  test "Use English name if no word specified" do
    assert_equal '<a class="sp_link" href="/species/Jynx_torquilla">Wryneck</a>',
      transform("{{jyntor|en}}")
  end

  # Posts

  test "properly parse post by code {{#see this|some-post}}" do
    blogpost = create(:post, post_core: create(:post_core, slug: "some-post"))
    assert_equal "\"see this\":some-post\n\n[some-post]#{public_post_path(blogpost)}",
      transform("{{#see this|some-post}}")
  end

  # Images

  test "render image by slug {{^slug}}" do
    image = create(:image)
    result = transform("{{^#{image.slug}}}")
    assert_includes result, '<figure class="imageholder">'
    assert_includes result, image.decorated.title
    assert_includes result, 'width="800" height="600"'
    assert_includes result, 'style="max-width: min(100%, calc(max(97vh, 700px) * 800 / 600))"'
  end

  test "render image with unknown dimensions without width/height attributes" do
    image = create(:image, assets_cache: ImageAssetsArray.new([ImageAssetItem.new(:local, 0, 0, "/photos/no-dims.jpg")]))
    result = transform("{{^#{image.slug}}}")
    assert_includes result, "<img src="
    assert_not_includes result, "width="
  end

  test "render two images by slug in one text" do
    image1 = create(:image)
    image2 = create(:image)
    result = transform("{{^#{image1.slug}}} and {{^#{image2.slug}}}")
    assert_equal 2, result.scan('<figure class="imageholder">').size
  end

  test "ignore unknown image slug" do
    assert_equal "", transform("{{^no-such-image}}")
  end

  # Allowed fallbacks

  test "ignore unknown species code (name provided)" do
    assert_equal "Emu", transform("{{Emu|dronov}}")
  end

  test "show unknown species code (no name provided)" do
    assert_equal "dronov", transform("{{dronov}}")
  end

  test "properly show unknown scientific name (name provided)" do
    assert_equal unknown_species("Emu", "Dromaius novaehollandiae"), transform("{{Emu|Dromaius novaehollandiae}}")
  end

  test "properly show unknown scientific name (no name provided)" do
    assert_equal unknown_species(nil, "Dromaius novaehollandiae"), transform("{{Dromaius novaehollandiae}}")
  end

  # Combined

  test "properly parse two species" do
    text = transform("{{Sparrows|pasdom}} and {{Barn Swallows|hirrus}}")
    assert_equal "<a class=\"sp_link\" href=\"/species/Passer_domesticus\">Sparrows</a> and <a class=\"sp_link\" href=\"/species/Hirundo_rustica\">Barn Swallows</a>", text
  end

  test "properly parse pipe in the second code" do
    blogpost = create(:post)
    slug = blogpost.slug
    assert_equal %Q(""Test Post"":#{slug} has <a class="sp_link" href="/species/Jynx_torquilla">Wrynecks</a>\n\n[#{slug}]#{public_post_path(blogpost)}),
      transform("{{##{slug}}} has {{Wrynecks|jyntor}}")
  end

  # HTML entities

  test "preserve HTML entities" do
    assert_equal "<a class=\"sp_link\" href=\"/species/Bombycilla_garrulus\">Linotte m&eacute;lodieuse</a>",
      transform("{{Linotte m&eacute;lodieuse|bomgar}}")
  end

  # Erroneous

  test "do not parse species with post or link modifier {{#jyntor}}" do
    assert_not_equal species_link(species(:jyntor), "Jynx torquilla"), transform("{{#jyntor}}")
    assert_not_equal species_link(species(:jyntor), "Jynx torquilla"), transform("{{@jyntor}}")
  end

  test "properly handle missed code" do
    assert_equal "vid", transform("{{vid|}}")
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
