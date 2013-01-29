module FormattedModel
  def formatted
    ModelFormatter.new(self)
  end
end
