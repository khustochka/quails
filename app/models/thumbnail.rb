class Thumbnail

  include Rails.application.routes.url_helpers
  include SpeciesHelper
  include ImagesHelper
  include ActionView::Helpers::TagHelper

  attr_reader :object

  def initialize(object)
    @object = object
  end

  def url
    case object
      when LocalSpecies
      then
        species_path(object.taxon)
      when Species
      then
        species_path(object)
    end
  end

  def title
    case object
      when LocalSpecies
      then
        ("%s %s" % [object.taxon.name, name_sci(object.taxon)]).html_safe
      when Species
      then
        ("%s %s" % [object.name, name_sci(object)]).html_safe
    end
  end

  def asset_url
    image_asset.full_url
  end

  def height
    THUMBNAIL_HEIGHT
  end

  def width
    (image_asset.width * (height.to_f / image_asset.height)).to_i
  end

  def to_partial_path
    'images/thumbnail'
  end

  private
  def image_asset
    case object
      when LocalSpecies
      then
        thumbnail_item(object.taxon.image)
      when Species
      then
        thumbnail_item(object.image)
    end
  end

end
