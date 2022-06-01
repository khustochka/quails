# frozen_string_literal: true

module DecoratedModel
  def decorated(metadata = {})
    ("#{self.class.name}Decorator").constantize.new(self, metadata)
  end
end
