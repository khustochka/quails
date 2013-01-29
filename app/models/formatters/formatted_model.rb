module FormattedModel

  MAPPING = {
      Post => PostFormatter
  }

  def formatted
    MAPPING[self.class].new(self)
  end
end
