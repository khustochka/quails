# frozen_string_literal: true

class ModelDecorator
  def initialize(model, metadata = {})
    @model = model
    @metadata = metadata
  end
end
