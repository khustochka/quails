# frozen_string_literal: true

require "test_helper"

class CountriesControllerTest < ActionController::TestCase
  setup do
    @image = create(:image)
    assert species(:pasdom).image
    @obs = @image.observations.first
  end

  test "Birds of Ukraine" do
    LocalSpecies.create(locus: loci(:ukraine), species: species(:pasdom), status: "")
    get :gallery, params: { country: "ukraine" }
    assert_response :success
    assert_predicate assigns(:thumbs), :present?
    assert_select "a[href='#{species_path(@obs.species)}']"
  end

  test "og:image meta tag is present for gallery page on cached response" do
    LocalSpecies.create(locus: loci(:ukraine), species: species(:pasdom), status: "")

    # Enable caching to reproduce the bug: @meta_thumbnail was set inside a cache block,
    # so on cache hit the variable was never assigned and og:image disappeared.
    @controller.perform_caching = true
    cache_store = ActiveSupport::Cache::MemoryStore.new
    ActionController::Base.cache_store = cache_store

    # First request populates the cache
    get :gallery, params: { country: "ukraine" }
    assert_select "meta[property='og:image']" do |elements|
      assert_includes elements.first["content"], "cuckoo-thumb"
    end
    # Second request hits the cache — og:image must still be present
    get :gallery, params: { country: "ukraine" }
    assert_select "meta[property='og:image']" do |elements|
      assert_includes elements.first["content"], "cuckoo-thumb"
    end
  ensure
    @controller.perform_caching = false
    ActionController::Base.cache_store = :null_store
  end

  test "Birds of USA" do
    obs = create(:observation, card: create(:card, locus: loci(:nyc)))
    img = create(:image, observations: [obs])
    get :gallery, params: { country: "usa" }
    assert_response :success
    assert_predicate assigns(:thumbs), :present?, "Thumbnails must be present, were not."
    assert_select "a[href='#{image_path(img)}']"
  end

  test "Birds of UK" do
    uk = create(:locus, loc_type: "country", slug: "united_kingdom")
    london = create(:locus, parent: uk, slug: "london")
    obs = create(:observation, card: create(:card, locus: london))
    img = create(:image, observations: [obs])
    get :gallery, params: { country: "united_kingdom" }
    assert_response :success
    assert_predicate assigns(:thumbs), :present?
    assert_select "a[href='#{image_path(img)}']"
  end

  test "USA gallery is paginated" do
    obs = create(:observation, card: create(:card, locus: loci(:nyc)))
    create(:image, observations: [obs])

    get :gallery, params: { country: "usa" }
    assert_response :success
    assert_respond_to assigns(:thumbs), :current_page
    assert_equal 1, assigns(:thumbs).current_page
    assert_equal CountriesController::PER_PAGE, assigns(:thumbs).limit_value

    get :gallery, params: { country: "usa", page: 2 }
    assert_response :success
    assert_equal 2, assigns(:thumbs).current_page
  end
end
