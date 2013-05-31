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
    delete_if { |el| el.type == type }
  end

  def thumbnails
    ImageAssetsArray.new(select { |a| a.height == 100 || a.width == 100 })
  end

  def locals
    ImageAssetsArray.new(select { |a| a.type == :local })
  end

  def externals
    ImageAssetsArray.new(select { |a| a.type != :local })
  end

  def main_image
    find_max_size(width: 894)
  end

  # This proved to be faster than sort + find first
  def find_max_size(options)
    dimension = options.keys.first
    value = options.values.first
    inject do |found, another|
      if found.send(dimension) < value
        if another.send(dimension) > found.send(dimension)
          another
        else
          found
        end
      else
        if another.send(dimension) >= value && another.send(dimension) < found.send(dimension)
          another
        else
          found
        end
      end
    end
  end

end
