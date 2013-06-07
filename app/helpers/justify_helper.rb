module JustifyHelper
  BORDER = 4
  INCREASE_ENABLED = false

  def render_justified(array)
    render 'images/justified', array: array
  end

  def justify(thumbs)
    result = []
    current_row = []

    max_width = @wider ? 1120 : 896

    sum_width = 0
    temp_el = nil

    thumbs.each do |thumb|
      current_row << thumb
      pre_sum_width = sum_width
      sum_width += thumb.width + (BORDER * 2)
      Rails.logger.debug "sum_width=#{sum_width}"
      if sum_width > max_width
        ratio = max_width.to_f / sum_width

        if INCREASE_ENABLED
          if ratio < 0.85
            ratio = pre_sum_width.to_f / sum_width
            temp_el = current_row.pop
          end
        end

        new_height = (ImagesHelper::THUMBNAIL_HEIGHT * ratio).to_i
        new_widths = current_row.map {|th| (th.width * ratio).to_i}

        new_width = new_widths.sum + (BORDER * 2 * current_row.size)

        Rails.logger.debug "new_width=#{new_width}"

        #Reducing
        if new_width > max_width
          new_height -= ((new_width - max_width) / new_widths.size * 0.75).to_i
          (0..new_widths.size - 1).cycle do |idx|
            break if new_width == max_width
            new_widths[idx] -= 1
            new_width -= 1
          end
        end

        current_row.each_with_index do |el, idx|
          el.force_dimensions(width: new_widths[idx], height: new_height)
        end

        #Increasing
        # TODO: should force height and recalc total width

        Rails.logger.debug "adjusted_width=#{width(current_row)}"

        result << current_row
        current_row = []
        sum_width = 0
        if temp_el
          current_row << temp_el
          sum_width = temp_el.width + (BORDER * 2)
          temp_el = nil
        end

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
