# frozen_string_literal: true

class SimplePartial
  def initialize(partial_path)
    @partial_path = partial_path
  end

  def to_partial_path
    @partial_path
  end
end
