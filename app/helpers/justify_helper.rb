module JustifyHelper
  BORDER = 4

  def render_justified(array)
    render 'images/justified', array: array
  end

  def justify(thumbs)
    result = []
    current_row = []

    max_width = @wider ? 1120 : 896

    sum_width = 0

    thumbs.each do |thumb|
      current_row << thumb
      sum_width += thumb.width + (BORDER * 2)
      if sum_width > max_width * 1.1
        ratio = max_width.to_f / sum_width
        new_width = current_row.inject(0) do |nw, th|
          w = (th.width * ratio).to_i
          th.force_width(w)
          nw + w + (BORDER * 2)
        end
        #p "new_width=#{new_width}"
        if new_width > max_width
          current_row.cycle do |el|
            break if new_width == max_width
            #p el.width
            el.force_width(el.width - 1)
            new_width -= 1
            #p el.width
          end
        end


        #p "adjusted_width=#{width(current_row)}"

        result << current_row
        current_row = []
        sum_width = 0

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
