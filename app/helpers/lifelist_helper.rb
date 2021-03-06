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
    else
      nil
    end
  end

  def ebird_lifelist
    Lifelist::Ebird.new
  end
end
