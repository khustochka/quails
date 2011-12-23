module CommonValueSelector
  def if_common_value(key)
    a = map {|v| v[key]}.uniq
    a.size == 1 ? a.first : nil
  end
end