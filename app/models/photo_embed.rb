# frozen_string_literal: true

class PhotoEmbed
  attr_reader :media, :desired_width

  delegate :width, :height, to: :imagetaggable

  def initialize(media, desired_width:)
    @media = media
    @desired_width = desired_width
  end

  def imagetaggable
    @imagetaggable ||= primary_asset.variant_of_width(desired_width * orientation_ratio)
  end

  def sizes
    max_possible_width.yield_self do |max_width|
      "(min-width: #{max_width}px) #{max_width}px, 100vw"
    end
  end

  def srcset
    primary_asset.srcset
  end

  private

  def max_possible_width
    imagetaggable.width
  end

  def primary_asset
    @primary_asset ||= media.stored_image.attached? ? media.stored_image.extend(StoredImage) : media.external_asset
  end

  # Smaller width is sufficient for portrait (vertical) images
  def orientation_ratio
    primary_asset.portrait? ? 0.66 : 1
  end
end
