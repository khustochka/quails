module FormattedModel

  def formatted(metadata = {})
    ("#{self.class.name}Formatter").constantize.new(self, metadata)
  end
end
