# frozen_string_literal: true

module LifelistHelper
  def sorted_list_partial(sort)
    case sort
    when nil, "last"
      "lifelist/advanced/by_date"
    when "class"
      "lifelist/advanced/by_class"
    when "count"
      "lifelist/advanced/by_count"
    end
  end

  def ebird_lifelist
    Lifelist::EBird.new
  end

  # Used in charts, to visually represent 0 species as a 1px bar, as opposed to nothing
  def percent_or_pixel(number)
    number.to_f.zero? ? "1px" : "#{number}%"
  end
end
