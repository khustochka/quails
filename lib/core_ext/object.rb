# frozen_string_literal: true

class Object
  def if_present(&block)
    if present?
      yield_self(&block)
    end
  end

  # Like present?, but also accepts `false`. For query values, where false has meaning.
  def meaningful?
    present?
  end
end

class FalseClass # rubocop:disable Style/OneClassPerFile
  def meaningful?
    true
  end
end
