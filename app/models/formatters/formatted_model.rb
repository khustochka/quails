module FormattedModel

  MAPPING = {
      Post => PostFormatter,
      Image => ImageFormatter,
      Comment => CommentFormatter
  }

  def formatted
    MAPPING[self.class].new(self)
  end
end
