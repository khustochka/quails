# frozen_string_literal: true

require "deflicker/service"

class FlickrToStorageJob < ApplicationJob
  queue_as :default

  def perform(image)
    # Only performed by admin. Will be removed in the future.
    # rubocop:disable Security/Open
    asset = image.assets_cache.externals.find { |a| a.url.match?(/_o.jpg$/i) }&.url
    image.stored_image.attach(io: URI.open(asset), filename: "#{image.slug}.jpg")
    Deflicker::Service.new.match_to_site
  end
end
