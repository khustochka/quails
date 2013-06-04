class Thumbnail

  class Title
    attr_reader :object

    def initialize(object, partial)
      @partial = partial
      @object = object
    end

    def to_partial_path
      @partial
    end
  end

  include ImagesHelper

  attr_reader :url, :data

  def initialize(url_or_object, title_or_partial, image, data = nil)
    @url = url_or_object
    @title_or_partial = title_or_partial
    @image = image
    @data = data
  end

  def title
    case @title_or_partial
      when String
        @title_or_partial
      when Hash
        @cached_title = Title.new(@url, @title_or_partial[:partial])
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
    thumbnail_item(@image)
  end

end
