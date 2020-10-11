# frozen_string_literal: true

class ImageAssetsArray < Array
  def self.dump(arr)
    arr.map do |el|
      ImageAssetItem.dump(el)
    end.join("\n")
  end

  def self.load(str)
    return nil if str.nil?
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
    find_max_size(width: 894, height: 768)
  end

  def thumbnail
    find_max_size(height: ImagesHelper::THUMBNAIL_HEIGHT)
  end

  def original
    max_by(&:width)
  end

  # This proved to be faster than sort + find first
  def find_max_size(options)
    dimensions = options.keys
    inject do |found, another|
      if dimensions.all? { |d| found.send(d) < options[d] }
        if dimensions.any? { |d| another.send(d) > found.send(d) }
          another
        else
          found
        end
      else
        if dimensions.any? { |d| another.send(d) > options[d] } &&
            dimensions.any? { |d| another.send(d) < found.send(d) }
          another
        else
          found
        end
      end
    end
  end

end
