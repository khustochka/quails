module ImagesHelper

  FLICKR_SIZES = {
      "NO FLICKR" => '',
      "Square" => 's',
      "Thumbnail" => 't',
      "Small" => 'm',
      "Medium" => '-',
      "Medium 640" => 'z',
      "Large" => 'b',
      "Original" => 'o'
  }

  LIST_FOR_PICTURED_SPECIES = {
      true => :ol,
      false => :ul
  }

  SENTENCE_SEPARATOR_DEPENDING_ON_POST = {
      true => ';',
      false => '.'
  }

  def list_type_for_image_species(image)
    LIST_FOR_PICTURED_SPECIES[image.multi?]
  end

  def sentence_separator_depending_on_post(post)
    SENTENCE_SEPARATOR_DEPENDING_ON_POST[post.present?]
  end

  def jpg_url(img)
    (img.on_flickr? && img.flickr_data['Original']['source']) ||
        legacy_image_url("#{img.slug}.jpg")
  end

  def thumbnail_url(img)
    (img.on_flickr? && img.flickr_data['Thumbnail']['source']) ||
        legacy_image_url("tn_#{img.slug}.jpg")
  end

  # TODO: Use Addressable::URI to parse and generate urls (better than stdlib's URI)
  def self.image_host=(host)
    @image_host = host
  end

  private

  def self.image_host
    Configurator.configure(ImagesHelper) unless @image_host
    @image_host
  end

  def legacy_image_url(file_name)
    "#{ImagesHelper.image_host}/#{file_name}"
  end

end
