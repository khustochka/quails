module JustifyHelper
  BORDER = 4
  MAX_WIDTH = 968

  def justify(thumbs)
    result = []
    current_row = []

    init_height = ImagesHelper::THUMBNAIL_HEIGHT


    thumbs.each do |thumb|
      current_row << thumb
      sum_width = width(current_row)
      if sum_width > MAX_WIDTH * 1.01
        ratio = MAX_WIDTH.to_f / sum_width
        current_row.each { |th| th.force_width((th.width * ratio).to_i) }

        new_width = width(current_row)
        if new_width > MAX_WIDTH
          current_row.cycle do |el|
            puts new_width - MAX_WIDTH
            break if new_width == MAX_WIDTH
            el.force_width(el.width - 1)
            new_width -= 1
          end
        end

        result << current_row
        current_row = []

      end
    end

    result << current_row

    result
  end

  private
  def width(thumbs)
    thumbs.inject(0) { |memo, t| memo + t.width + (BORDER * 2) }
  end
end
