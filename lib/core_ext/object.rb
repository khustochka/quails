# frozen_string_literal: true

class Object
  def if_present(&block)
    unless blank?
      yield_self &block
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
