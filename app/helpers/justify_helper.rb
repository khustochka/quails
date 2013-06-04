module JustifyHelper
  BORDER = 4

  def justify(thumbs)
    result = []
    current_row = []

    max_width = @wider ? 1120 : 896


    thumbs.each do |thumb|
      current_row << thumb
      sum_width = width(current_row)
      if sum_width > max_width * 1.01
        ratio = max_width.to_f / sum_width
        current_row.each { |th| th.force_width((th.width * ratio).to_i) }

        new_width = width(current_row)
        if new_width > max_width
          current_row.cycle do |el|
            break if new_width == max_width
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
