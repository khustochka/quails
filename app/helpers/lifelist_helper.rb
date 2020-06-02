module LifelistHelper
  def sorted_list_partial(sort)
    case sort
    when nil, "last"
      "lists/advanced/by_date"
    when "class"
      "lists/advanced/by_class"
    when "count"
      "lists/advanced/by_count"
    else
      nil
    end
  end
end
