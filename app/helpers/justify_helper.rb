module JustifyHelper
  BORDER = 4
  MAX_WIDTH = 968

  def justify(thumbs)
    result = []
    current_row = []

    init_height = ImagesHelper::THUMBNAIL_HEIGHT


    thumbs.each do |thumb|
      sum_width = width(current_row + [thumb])
      if sum_width > MAX_WIDTH
        ratio = MAX_WIDTH.to_f / sum_width

        if ratio < 0.85
          current_row << thumb
          current_row.each {|th| th.force_width((th.width * ratio).to_i) }
          result << current_row
          current_row = []
        else
          ratio = MAX_WIDTH.to_f / width(current_row)
          current_row.each {|th| th.force_width((th.width * ratio).to_i) }
          result << current_row
          current_row = [thumb]
        end
      else
        current_row << thumb
      end
    end

    result << current_row

    result
  end

  private
  def width(thumbs)
    thumbs.inject(0) {|memo, t| memo + t.width + (BORDER * 2) }
  end
end
