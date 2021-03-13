# frozen_string_literal: true

class ImageAssetItem < Struct.new(:type, :width, :height, :url)

  TYPE_TO_STR = {local: "l", flickr: "f", youtube: "y", amazon: "a"} # "a" not used
  STR_TO_TYPE = TYPE_TO_STR.invert

  def self.dump(obj)
    [TYPE_TO_STR[obj.type], obj.width, obj.height, obj.url].join(",")
  end

  def self.load(str)
    t, w, h, u = str.split(",")
    new(STR_TO_TYPE[t], w.to_i, h.to_i, u)
  end

  def inspect
    sprintf('%s: "%dx%d" %s', type, width, height, url.inspect)
  end

  def full_url
    if type == :local
      "#{ImagesHelper.image_host}#{url}"
    else
      url
    end
  end

  def width
    super || 600
  end

  def height
    super || 400
  end

  def dummy_dimensions?
    !self[:width] || !self[:height]
  end

end
