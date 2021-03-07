# frozen_string_literal: true

module DecoratedModel

  def decorated(metadata = {})
    @decorated ||= ("#{self.class.name}Formatter").constantize.new(self, metadata)
  end
end
