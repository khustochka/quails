class ImageAssetItem < Struct.new(:type, :width, :height, :url)

  TYPE_TO_STR = {local: "l", flickr: "f"}
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
      "#{ImagesHelper.image_host}/#{url}"
    else
      url
    end
  end

end
