module FormattedModel

  MAPPING = {
      Post => PostFormatter,
      Image => ImageFormatter
  }

  def formatted
    MAPPING[self.class].new(self)
  end
end
