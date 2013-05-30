class ImageAssetsArray < Array
  def self.dump(arr)
    arr.map do |el|
      ImageAssetItem.dump(el)
    end.join("\n")
  end

  def self.load(str)
    ImageAssetsArray.new(
        str.split("\n").map do |line|
          ImageAssetItem.load(line)
        end
    )
  end

  def swipe(type)
    delete_if {|el| el.type == type}
  end
end
