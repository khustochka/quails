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
end
