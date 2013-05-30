class ImageAssetItem < Struct.new(:type, :width, :height, :url)

  def self.dump(obj)
    [obj.type, obj.width, obj.height, obj.url].join(",")
  end

  def self.load(str)
    t, w, h, u = str.split(",")
    new(t.to_sym, w.to_i, h.to_i)
  end

end
