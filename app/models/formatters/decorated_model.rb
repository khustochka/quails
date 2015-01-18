module DecoratedModel

  def decorated(metadata = {})
    ("#{self.class.name}Formatter").constantize.new(self, metadata)
  end
end
