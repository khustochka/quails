class Object
  def if_present(&block)
    unless blank?
      tap &block
    end
  end

  # Like present?, but also accepts `false`. For query values, where false has meaning.
  def meaningful?
    present?
  end
end

class FalseClass
  def meaningful?
    true
  end
end
