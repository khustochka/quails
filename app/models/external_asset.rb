# frozen_string_literal: true

class ExternalAsset < ApplicationRecord
  EXTERNAL_SERVICES = %w[ flickr youtube ]

  belongs_to :media, inverse_of: :external_asset, touch: true
  has_many :external_asset_variants, inverse_of: :external_asset

  # For Flickr photos analyzed means variants are created
  store :metadata, accessors: [:analyzed, :width, :height], coder: ActiveRecord::Coders::JSON

  validates :service_name, presence: true, inclusion: { in: EXTERNAL_SERVICES }
  validates :external_key, presence: true, uniqueness: { scope: :service_name }

  def variant_of_width(desired_width)
    # TODO: try to use variation_key, it is width, but can have "o" at the end
    external_asset_variants.sort_by(&:width).yield_self do |sorted_variants|
      sorted_variants.find { |v| v.width >= desired_width } || sorted_variants.last
    end
  end

  def srcset
    # Remove smallest thumbnails, some of which are cropped
    items = external_asset_variants.sort_by(&:width).delete_if {|item| item.width <= 150}
    items.map {|item| [item.url, "#{item.width}w"]}
  end

  def portrait?
    width && height && height >= width
  end
end
