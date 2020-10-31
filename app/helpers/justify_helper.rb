# frozen_string_literal: true

module JustifyHelper
  BORDER = 4
  INCREASE_ENABLED = true

  def render_justified(array)
    render "images/justified", array: array
  end

  def justify(thumbs)
    result = []
    current_row = []

    max_width = (@body_class == "wider") ? 1120 : 896

    sum_width = 0
    temp_el = nil
    num_thumbs = 0

    thumbs.each do |thumb|
      current_row << thumb
      pre_sum_width = sum_width
      sum_width += thumb.width + (BORDER * 2)
      num_thumbs += 1
      Rails.logger.debug "sum_width=#{sum_width}"
      if sum_width > max_width
        border_sum = num_thumbs * (BORDER * 2)
        ratio = (max_width.to_f - border_sum) / (sum_width - border_sum)

        if INCREASE_ENABLED
          if ratio < 0.85
            num_thumbs -= 1
            border_sum = num_thumbs * (BORDER * 2)
            ratio = (max_width.to_f - border_sum) / (pre_sum_width - border_sum)
            temp_el = current_row.pop
          end
        end

        new_height = (ImagesHelper::THUMBNAIL_HEIGHT * ratio).to_i
        new_widths = current_row.map { |th| (th.width * ratio).to_i }

        new_width = new_widths.sum + (BORDER * 2 * current_row.size)

        Rails.logger.debug "new_width=#{new_width}"

        # Pixel adjustment
        if new_width != max_width
          delta = (max_width - new_width)
          pixel = delta / delta.abs

          new_height += (delta * pixel / new_widths.size * 0.75).to_i
          (0..new_widths.size - 1).cycle do |idx|
            break if new_width == max_width
            new_widths[idx] += pixel
            new_width += pixel
          end
        end

        current_row.each_with_index do |el, idx|
          el.force_dimensions(width: new_widths[idx], height: new_height)
        end

        Rails.logger.debug "adjusted_width=#{width(current_row)}"

        result << current_row
        current_row = []
        sum_width = 0
        num_thumbs = 0
        if temp_el
          current_row << temp_el
          sum_width = temp_el.width + (BORDER * 2)
          num_thumbs += 1
          temp_el = nil
        end

      end
    end

    if current_row.any?
      border_sum = num_thumbs * (BORDER * 2)
      ratio = (max_width.to_f - border_sum) / (sum_width - border_sum)

      if ratio < 1.2
        new_height = (ImagesHelper::THUMBNAIL_HEIGHT * ratio).to_i
        new_widths = current_row.map { |th| (th.width * ratio).to_i }

        new_width = new_widths.sum + (BORDER * 2 * current_row.size)

        Rails.logger.debug "new_width=#{new_width}"

        # Pixel adjustment
        if new_width != max_width
          delta = (max_width - new_width)
          pixel = delta / delta.abs

          new_height += (delta * pixel / new_widths.size * 0.75).to_i
          (0..new_widths.size - 1).cycle do |idx|
            break if new_width == max_width
            new_widths[idx] += pixel
            new_width += pixel
          end
        end

        current_row.each_with_index do |el, idx|
          el.force_dimensions(width: new_widths[idx], height: new_height)
        end

        Rails.logger.debug "adjusted_width=#{width(current_row)}"
      end

      result << current_row
    end
    result
  end

  private
  def width(thumbs)
    thumbs.inject(0) { |memo, t| memo + t.width + (BORDER * 2) }
  end
end
