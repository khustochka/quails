# frozen_string_literal: true

class FlickrToStorageJob < ApplicationJob
  queue_as :default

  def perform(image)
    # Only performed by admin. Will be removed in the future.
    asset = image.assets_cache.externals.find { |a| a.url.match?(/_o.jpg$/i) }&.url
    image.stored_image.attach(io: URI.open(asset), filename: "#{image.slug}.jpg") # rubocop:disable Security/Open
  end
end
