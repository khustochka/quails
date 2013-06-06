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
    new_height = 0

    thumbs.each do |thumb|
      current_row << thumb
      pre_sum_width = sum_width
      sum_width += thumb.width + (BORDER * 2)
      if sum_width > max_width * 1.1
        ratio = max_width.to_f / sum_width

        if INCREASE_ENABLED
          if ratio < 0.85
            ratio = pre_sum_width.to_f / sum_width
            temp_el = current_row.pop
          end
        end

        new_height = (ImagesHelper::THUMBNAIL_HEIGHT * ratio).to_i
        new_width = current_row.inject(0) do |nw, th|
          w = (th.width * ratio).to_i
          th.force_dimensions(width: w, height: new_height)
          nw + w + (BORDER * 2)
        end
        #p "new_width=#{new_width}"

        #Reducing
        if new_width > max_width
          current_row.cycle do |el|
            break if new_width == max_width
            #p el.width
            el.force_dimensions(width: el.width - 1, height: new_height)
            new_width -= 1
            #p el.width
          end
        end

        #Increasing
        # TODO: should force height and recalc total width

        #p "adjusted_width=#{width(current_row)}"

        result << current_row
        current_row = []
        sum_width = 0
        if temp_el
          current_row << temp_el
          sum_width = temp_el.width + (BORDER * 2)
          temp_el = nil
          new_height = 0
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
