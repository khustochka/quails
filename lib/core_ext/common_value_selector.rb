module CommonValueSelector

  # Operates over Array of Hashes (or any other Enumerable, elements responding to #[])
  # If all the elements have the same value under 'key', returs this value
  def common_value(key)
    a = map {|v| v[key]}.uniq
    a.size == 1 ? a.first : nil
  end
end